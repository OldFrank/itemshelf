// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008, ItemShelf Development Team. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <arpa/inet.h>
#import <fcntl.h>

#import "WebServer.h"
#import "Database.h"
#import "Item.h"

#define PORT_NUMBER		8888

@implementation WebServer

/**
   Start web server
*/
- (BOOL)startServer
{
    int on;
    struct sockaddr_in addr;

    listenSock = socket(AF_INET, SOCK_STREAM, 0);
    if (listenSock < 0) {
        return NO;
    }

    on = 1;
    setsockopt(listenSock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(PORT_NUMBER);

    if (bind(listenSock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        close(listenSock);
        return NO;
    }
	
    socklen_t len = sizeof(serv_addr);
    if (getsockname(listenSock, (struct sockaddr *)&serv_addr, &len)  < 0) {
        close(listenSock);
        return NO;
    }

    if (listen(listenSock, 16) < 0) {
        close(listenSock);
        return NO;
    }

    [self retain];
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
    [thread start];
	
    return YES;
}

/**
   Stop web server
*/
- (void)stopServer
{
    if (listenSock >= 0) {
        close(listenSock);
    }
    listenSock = -1;
}

/**
   Decide server URL
*/
- (NSString*)serverUrl
{
    // connect dummy UDP socket to get local IP address.
    int s = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(0x01010101); // dummy address
    addr.sin_port = htons(80);
	
    if (connect(s, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(s);
        return nil;
    }
	
    socklen_t len = sizeof(addr);
    getsockname(s, (struct sockaddr*)&addr, &len);
    close(s);

    char addrstr[64];
    inet_ntop(AF_INET, (void*)&addr.sin_addr.s_addr, addrstr, sizeof(addrstr));

    NSString *url;
    if (PORT_NUMBER == 80) {
        url = [NSString stringWithFormat:@"http://%s", addrstr];
    } else {
        url = [NSString stringWithFormat:@"http://%s:%d", addrstr, PORT_NUMBER];
    }
    return url;
}

/**
   Server thread
*/
- (void)threadMain:(id)dummy
{	
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
	
    socklen_t len;
    struct sockaddr_in caddr;
	
    for (;;) {
        len = sizeof(caddr);
        serverSock = accept(listenSock, (struct sockaddr *)&caddr, &len);
        if (serverSock < 0) {
            break;
        }

        [self handleHttpRequest];

        close(serverSock);
    }

    if (listenSock >= 0) {
        close(listenSock);
    }
    listenSock = -1;
	
    [pool release];

    [self release];
    [NSThread exit];
}

/**
   Read http header line
*/
- (BOOL)readLine:(char *)line size:(int)size
{
    char *p = line;

    while (p < line + size) {
        int len = read(serverSock, p, 1);
        if (len <= 0) {
            return NO;
        }
        if (p > line && *p == '\n' && *(p-1) == '\r') {
            *(p-1) = 0; // null terminate;
            return YES;
        }
        p++;
    }
    return NO; // not reach here...
}

/**
   Recv http body
*/
- (char *)readBody:(int)contentLength
{
    char *buf, *p;
    int len, remain;

    if (contentLength < 0) {
        len = 1024*10; // ad hoc
    } else {
        len = contentLength;
    }
    
    buf = malloc(len + 1);
    p = buf;
    remain = len;

    while (remain > 0) {
        int rlen = read(serverSock, p, remain);
        if (rlen < 0) {
            free(buf);
            return NULL;
        }
        if (contentLength < 0) break;

        p += rlen;
        remain -= rlen;
    }

    *p = 0; // null terminate;
    return buf;
}

/**
   Handle http request
*/
- (void)handleHttpRequest
{
    char line[1024];
    int lineno = 0;
    NSString *filereq = @"/";
    int contentLength = -1;

    // read headers
    for (;;) {
        if (![self readLine:line size:1024]) {
            return; // error
        }
        NSLog(@"%s", line);
        
        if (strlen(line) == 0) {
            break; // end of header
        }

        if (lineno == 0) {
            // request line
            char *p, *p2;
            p = strtok(line, " ");
            if (p) p2 = strtok(NULL, " ");
            if (p2) filereq = [NSString stringWithCString:p2];
        }

        else if (strncasecmp(line, "Content-Length:", 15) == 0) {
            contentLength = atoi(line + 15);
        }

        lineno++;
    }

    // read body
    char *body = NULL;
    if (contentLength > 0) {
        body = [self readBody:contentLength];
    }

    [self requestHandler:(NSString*)filereq body:body bodylen:contentLength];

    free(body);
}

/**
   Request handler

   @note You need to override this method
*/
- (void)requestHandler:(NSString*)filereq body:(char *)body bodylen:(int)bodylen
{
    // must be override

    [self sendString:@"HTTP/1.0 404 Not Found\r\n"];
    [self sendString:@"Content-Type: text/html; charset=iso-8859-1;\r\n"];
    [self sendString:@"\r\n"];

    [self sendString:@"<html><head><title>404 Not Found</title></head>\n"];
    [self sendString:@"<body><h1>Not Found</h1>\n"];
    [self sendString:@"<p>The requested URL "];
    [self sendString:filereq];
    [self sendString:@" is not found on this server.</p>"];
    [self sendString:@"</body></html>"];
}

/**
   Send reply in string
*/
- (void)sendString:(NSString *)string
{
    write(serverSock, [string UTF8String], [string length]);
}

@end
