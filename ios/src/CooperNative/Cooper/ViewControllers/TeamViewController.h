//
//  TeamViewController.h
//  CooperNative
//
//  Created by sunleepy on 12-9-14.
//  Copyright (c) 2012年 codesharp. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavigationController.h"
#import "TeamTaskViewController.h"
#import "CooperService/TeamService.h"
#import "CooperRepository/TeamDao.h"
#import "CooperRepository/TeamMemberDao.h"
#import "CooperRepository/ProjectDao.h"
#import "CooperRepository/TagDao.h"

@interface TeamViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    UIView *backBtn;
    UIView *syncBtn;
    UIButton *settingBtn;
    UITableView *teamTableView;
    
    TeamService *teamService;
    
    TeamDao *teamDao;
    TeamMemberDao *teamMemberDao;
    ProjectDao *projectDao;
    TagDao *tagDao;
}

@property (nonatomic, retain) NSMutableArray *teams;
@property (nonatomic, retain) BaseNavigationController *teamTaskNavController;

@end
