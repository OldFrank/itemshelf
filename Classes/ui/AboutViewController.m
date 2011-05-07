// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AboutViewController.h"
#import "Edition.h"

#define COPYRIGHT @"Copyright © 2008-2011, ItemShelf development team. All rights reserved."

static NSString *COPYRIGHT_ZEBRA = 
@"The ZBar Bar Code Reader is Copyright (C) 2007-2010 Jeff Brown"
" <spadix@users.sourceforge.net>\n"
"The QR Code reader is Copyright (C) 1999-2009 Timothy B. Terriberry <tterribe@xiph.org>\n\n"

"You can redistribute this library and/or modify it under the terms of the GNU"
"Lesser General Public License as published by the Free Software Foundation;"
"either version 2.1 of the License, or (at your option) any later version.\n\n"
 
"This library is distributed in the hope that it will be useful, but WITHOUT"
"ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS"
"FOR A PARTICULAR PURPOSE."
"See the GNU Lesser General Public License for more details.\n\n"
 
"You should have received a copy of the GNU Lesser General Public License along"
"with this library; if not, write to the Free Software Foundation, Inc.,"
"51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA\n\n"
 
"ISAAC is based on the public domain implementation by Robert J. Jenkins Jr.,"
"and is itself public domain. \n\n"
 
"Portions of the bit stream reader are copyright (C) The Xiph.Org Foundation"
"1994-2008, and are licensed under a BSD-style license.\n\n"
 
"The Reed-Solomon decoder is derived from an implementation (C) 1991-1995 Henry"
"Minsky (hqm@ua.com, hqm@ai.mit.edu), and is licensed under the LGPL with"
"permission.";


@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"About", @"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *ret = nil;
    switch (section) {
    case 0:
        ret = @"About";
        break;
    case 1:
        ret = @"Credits";
        break;
    }
    return ret;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int ret = 0;
    switch (section) {
    case 0:
        ret = 3;
        break;
    case 1:
        ret = 2;
        break;
    }
    return ret;
}

// Customize cell heights
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = tableView.rowHeight;	

    switch (indexPath.section) {
    case 0:
        switch (indexPath.row) {
        case 0: // icon
            height = 80;
            break;
        }
        break;
			
    case 1:
        switch (indexPath.row) {
        case 0:
            height = 60;
            break;
        case 1:
            height = 450;
            break;
        }
        break;
    }
    return height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AboutCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    NSString *version;
    NSString *aptitle;
    UILabel *clabel;
    UIImage *iconImage;
	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;	
	
    switch (indexPath.section) {
    case 0:
        switch (indexPath.row) {
        case 0:
            if ([Edition isLiteEdition]) {
                iconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon-lite" ofType:@"png"]];
            } else {
                iconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];
            }
            cell.imageView.image = iconImage;
            if ([Edition isLiteEdition]) {
                aptitle = @"ItemShelf Lite";
            } else {
                aptitle = NSLocalizedString(@"AppName", @"");
            }
            cell.textLabel.text = aptitle;
            break;

        case 1:
            version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
            cell.textLabel.text = [NSString stringWithFormat:@"Version %@", version];
            break;
					
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Support site", @"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        break;
			
    case 1:
        switch (indexPath.row) {
        case 0:
            clabel = cell.textLabel; //[[[UILabel alloc] initWithFrame:CGRectMake(20, 5, 270, 50)] autorelease];
            clabel.lineBreakMode = UILineBreakModeWordWrap;
            clabel.numberOfLines = 0;
            clabel.font = [UIFont boldSystemFontOfSize:14.0];
            clabel.text = COPYRIGHT;
            //[cell addSubview:clabel];
            break;
					
        case 1:
            clabel = cell.textLabel; //[[[UILabel alloc] initWithFrame:CGRectMake(20, 5, 270, 40)] autorelease];
            clabel.lineBreakMode = UILineBreakModeWordWrap;
            clabel.numberOfLines = 200;
            clabel.font = [UIFont boldSystemFontOfSize:10.0];
            clabel.text = COPYRIGHT_ZEBRA;
            //[cell addSubview:clabel];
            break;
        }
        break;
    }

    return cell;
}

// セルタップ時の処理					
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        // URL タップ
        NSURL *url = [NSURL URLWithString:NSLocalizedString(@"SupportURL", @"")];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
