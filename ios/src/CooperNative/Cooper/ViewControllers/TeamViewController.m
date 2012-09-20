//
//  TeamViewController.m
//  CooperNative
//
//  Created by sunleepy on 12-9-14.
//  Copyright (c) 2012年 codesharp. All rights reserved.
//

#import "TeamViewController.h"
#import "CustomToolbar.h"

@implementation TeamViewController

@synthesize teams;
@synthesize setting_navViewController;
@synthesize teamTaskViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog("viewDidLoad事件触发");
    
    teamService = [[TeamService alloc] init];
    teamDao = [[TeamDao alloc] init];
    teamMemberDao = [[TeamMemberDao alloc] init];
    projectDao = [[ProjectDao alloc] init];
    tagDao = [[TagDao alloc] init];
	
    self.title = @"团队任务";
    
    teamTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    teamTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:APP_BACKGROUNDIMAGE]];
    teamTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    teamTableView.dataSource = self;
    teamTableView.delegate = self;
    [self.view addSubview:teamTableView];
    
    UITapGestureRecognizer *recognizer = nil;
    //左上自定义导航
    CustomToolbar *toolBar = [[CustomToolbar alloc] initWithFrame:CGRectMake(0, 0, 120, 45)];
    
    //左上后退按钮
    backBtn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 45)];
    UIImageView *backImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 27, 27)] autorelease];
    UIImage *backImage = [UIImage imageNamed:BACK_IMAGE];
    backImageView.image = backImage;
    [backBtn addSubview:backImageView];
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToOption:)];
    [backBtn addGestureRecognizer:recognizer];
    [recognizer release];
    [toolBar addSubview:backBtn];
    
    //左上同步按钮
    syncBtn = [[UIView alloc] initWithFrame:CGRectMake(40, 0, 38, 45)];
    UIImageView *settingImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 27, 27)] autorelease];
    UIImage *settingImage = [UIImage imageNamed:REFRESH_IMAGE];
    settingImageView.image = settingImage;
    [syncBtn addSubview:settingImageView];
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(syncTeam:)];
    [syncBtn addGestureRecognizer:recognizer];
    [recognizer release];
    [toolBar addSubview:syncBtn];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    [barButtonItem release];
    
    [toolBar release];
    
    //设置右选项卡中的按钮
    settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(0, 10, 27, 27);
    [settingBtn setBackgroundImage:[UIImage imageNamed:SETTING_IMAGE] forState:UIControlStateNormal];
    [settingBtn addTarget: self action: @selector(settingAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItem = settingButtonItem;
    [settingButtonItem release];
    
    //登录用户进行同步
    [self getTeams:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog("viewWillAppear事件触发")
    //如果未登录用户隐藏同步按钮
    syncBtn.hidden = [[ConstantClass instance] username].length == 0;
    
    [self loadTeamsData];
}

- (void)dealloc
{
    [teamService release];
    [teams release];
    [backBtn release];
    [syncBtn release];
    [settingBtn release];
    [teamTableView release];
    [teamDao release];
    [teamMemberDao release];
    [projectDao release];
    [tagDao release];
    [setting_navViewController release];
    [teamTaskViewController release];
    [super dealloc];
}

# pragma mark - UI相关

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teams.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
        selectedView.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1.0];
        //设置选中后cell的背景颜色
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = selectedView;
        [selectedView release];
    }
    
    Team* team = [self.teams objectAtIndex:indexPath.row];
    cell.textLabel.text = team.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //打开团队任务列表
    if (teamTaskViewController == nil)
    {
        teamTaskViewController = [[TeamTaskViewController alloc] init];
    }
    
    Team *team = [self.teams objectAtIndex:indexPath.row];
    
    teamTaskViewController.currentTeamId = team.id;
    teamTaskViewController.currentProjectId = nil;
    teamTaskViewController.currentMemberId = nil;
    teamTaskViewController.currentTag = nil;
    teamTaskViewController.needSync = YES;
    
    [Tools layerTransition:self.navigationController.view from:@"right"];
    [self.navigationController pushViewController:teamTaskViewController animated:NO];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - 相关动作事件

- (void) getTeams:(id)sender
{
    //登录用户进行同步
    if([[ConstantClass instance] username].length > 0)
    {
        self.HUD = [Tools process:LOADING_TITLE view:self.view];
        
        NSMutableDictionary *context = [NSMutableDictionary dictionary];
        [context setObject:@"GetTeams" forKey:REQUEST_TYPE];
        [teamService getTeams:context delegate:self];
    }
}

- (void) loadTeamsData
{
    NSLog(@"开始初始化所有团队数据");
    
    self.teams = [teamDao getTeams];
//    
//    //如果未登录用户并且无列表增加一条默认列表
//    if(tasklists.count == 0
//       && [[ConstantClass instance] username].length == 0)
//    {
//        Tasklist *tasklist = [tasklistDao addTasklist:@"0" :@"默认列表" :@"personal"];
//        [tasklistDao commitData];
//        
//        //添加
//        [tasklists addObject:tasklist];
//    }
//    
//    NSMutableArray *newRecentlyIds = [NSMutableArray array];
//    for(NSString *recentlyId in [[ConstantClass instance] recentlyIds])
//    {
//        int i = 0;
//        for(i = 0; i < tasklists.count; i++)
//        {
//            Tasklist *tasklist = [tasklists objectAtIndex:i];
//            if([tasklist.id isEqualToString:recentlyId])
//            {
//                break;
//            }
//        }
//        if(i < tasklists.count)
//        {
//            [newRecentlyIds addObject: recentlyId];
//        }
//    }
//    
//    [[ConstantClass instance] setRecentlyIds:newRecentlyIds];
//    [ConstantClass saveToCache];
    
    [teamTableView reloadData];
}

- (void)backToOption:(id)sender
{
    [Tools layerTransition:self.navigationController.view from:@"left"];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)syncTeam:(id)sender
{
    //登录用户进行同步
    if([[ConstantClass instance] username].length > 0)
    {
        self.HUD = [Tools process:LOADING_TITLE view:self.view];
        
        [self getTeams:sender];
    }
}

- (void)settingAction:(id)sender
{
    if(setting_navViewController == nil)
    {
        //设置
        SettingViewController *settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil setTitle:@"设置" setImage:SETTING_IMAGE];
        
        setting_navViewController = [[BaseNavigationController alloc] initWithRootViewController:settingViewController];
        
        //后退按钮
        UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBack.frame = CGRectMake(5, 5, 25, 25);
        [btnBack setBackgroundImage:[UIImage imageNamed:BACK_IMAGE] forState:UIControlStateNormal];
        [btnBack addTarget: self action: @selector(goBack:) forControlEvents: UIControlEventTouchUpInside];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
        settingViewController.navigationItem.leftBarButtonItem = backButtonItem;
        [self.navigationController presentModalViewController:setting_navViewController animated:YES];
        
        [backButtonItem release];
        [settingViewController release];
    }
    else
    {
        [self.navigationController presentModalViewController:setting_navViewController animated:YES];
    }
}

- (void)goBack:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"请求响应数据: %@, %d",request.responseString, request.responseStatusCode);
    NSDictionary *userInfo = request.userInfo;
    NSString *requestType = [userInfo objectForKey:REQUEST_TYPE];
    
    if([requestType isEqualToString:@"GetTeams"])
    {
        if(request.responseStatusCode == 200)
        {
            NSMutableArray *array = [[request responseString] JSONValue];
            
            //删除当前账户所有团队信息
            [teamDao deleteAll];
            [teamMemberDao deleteAll];
            [projectDao deleteAll];
            [tagDao deleteAll];
            
            for (NSMutableDictionary *teamDict in array)
            {
                NSString *teamId = [teamDict objectForKey:@"id"];
                NSString *name = [teamDict objectForKey:@"name"];
                NSMutableArray *membersArray = [teamDict objectForKey:@"members"];
                NSMutableArray *projectsArray = [teamDict objectForKey:@"projects"];
                NSMutableArray *tagsArray = [teamDict objectForKey:@"tags"];
                
                for (NSMutableDictionary *membersDict in membersArray)
                {
                    NSString *memberId = [membersDict objectForKey:@"id"];
                    NSString *memberName = [membersDict objectForKey:@"name"];
                    NSString *memberEmail = [membersDict objectForKey:@"email"];
                    
                    [teamMemberDao addTeamMember:teamId :memberId :memberName :memberEmail];
                    [teamMemberDao commitData];
                }

                for (NSMutableDictionary *projectsDict in projectsArray)
                {
                    NSString *projectId = [projectsDict objectForKey:@"id"];
                    NSString *projectName = [projectsDict objectForKey:@"name"];
                    
                    [projectDao addProject:teamId :projectId :projectName];
                    [projectDao commitData];
                }
                
                
                for (NSString *tagName in tagsArray)
                {
                    [tagDao addTag:tagName teamId:teamId];
                    [tagDao commitData];
                }
                     
                [teamDao addTeam:teamId :name];
                [teamDao commitData];
            }
            
            [Tools close:self.HUD];
            
            [self loadTeamsData];
        }
    }
}

@end
