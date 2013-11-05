//
//  ViewController.m
//  SmartVent
//
//  Created by Brice Dobry on 11/2/13.
//  Copyright (c) 2013 SmartVentures. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *CurrentSetTemp;
@property (weak, nonatomic) IBOutlet UIImageView *HouseImage;

@property (weak, nonatomic) IBOutlet UILabel *OutdoorTemp;
@property (weak, nonatomic) IBOutlet UILabel *HighTemp;
@property (weak, nonatomic) IBOutlet UILabel *LowTemp;

@property (weak, nonatomic) IBOutlet UIButton *HomeBtn;
@property (weak, nonatomic) IBOutlet UIButton *AwayBtn;
@property (weak, nonatomic) IBOutlet UIButton *NightBtn;
@property (weak, nonatomic) IBOutlet UIButton *VacationBtn;
@property (weak, nonatomic) IBOutlet UITableView *RoomTableView;

@property (weak, nonatomic) IBOutlet UIView *RoomView;
@property (weak, nonatomic) IBOutlet UILabel *RoomSetTemp;
@property (weak, nonatomic) IBOutlet UILabel *RoomTemp;
@property (weak, nonatomic) IBOutlet UIButton *OffButton;
@property (weak, nonatomic) IBOutlet UIImageView *RoomVent;

@property (strong, nonatomic) NSMutableArray *Rooms;
@property (strong, nonatomic) NSMutableArray *Temps;
@property (strong, nonatomic) NSMutableArray *SetTemps;
@property (strong, nonatomic) NSMutableArray *States;
@property (nonatomic) NSInteger ActiveRoom;

@end

//NSString * const SERVER_URL = @"http://obycode.com/smartventure/";
NSString * const SERVER_URL = @"http://192.168.38.62:8888/";

@implementation ViewController

-(void)updateHouseTemp {
    int total = 0, cnt = 0;
    for(NSNumber *temp in self.SetTemps) {
        int val = [temp intValue];
        if (val) {
            total += val;
            cnt++;
        }
    }
    if (cnt) {
        int average = total / cnt;
        self.CurrentSetTemp.text = [NSString stringWithFormat:@"%dº", average];
    } else {
        self.CurrentSetTemp.text = @"--";
    }
}

enum {
    VENT_CLOSED=0,
    VENT_HALF=50,
    VENT_OPEN=100
};

-(void)setVentStateForRoom:(int)roomId toState:(int)state  {
    NSString *urlString = [NSString stringWithFormat:@"%@set.php?room=%d&setpoint=%d", SERVER_URL, roomId, state];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    // Send the command to the controller
//    NSString *post = [NSString stringWithFormat:@"room=%d&setpoint=%d", roomId, state];
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding                            allowLossyConversion:YES];
//	
//    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://obycode.com/smartventure/set.php"]];
    
    // Specify that it will be a POST request
//    request.HTTPMethod = @"POST";
//    
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//	[request setHTTPBody:postData];
	
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (error)
            NSLog(@"%@", [error localizedDescription]);
    }];
//    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
//    if (err) {
//        NSLog(@"%@", [err localizedDescription]);
//    }
    
    // Update the current state
    [self.States replaceObjectAtIndex:roomId withObject:[NSNumber numberWithInt:state]];
    
    // If this is the active room, change the image
    if (self.ActiveRoom == roomId) {
        switch (state) {
            case VENT_OPEN:
                self.RoomVent.image = [UIImage imageNamed:@"Open.png"];
                break;
            case VENT_HALF:
                self.RoomVent.image = [UIImage imageNamed:@"HalfOpen.png"];
                break;
            case VENT_CLOSED:
                self.RoomVent.image = [UIImage imageNamed:@"Closed.png"];
                break;
            default:
                break;
        }
    }
}


-(void)checkVentStateForRoom:(int)roomId {
    int currentTemp = [[self.Temps objectAtIndex:roomId] intValue];
    int targetTemp = [[self.SetTemps objectAtIndex:roomId] intValue];
    int currentVentState = [[self.States objectAtIndex:roomId] intValue];
    
    // If the room is OFF, close the vent
    if (targetTemp == 0) {
        [self setVentStateForRoom:roomId toState:VENT_CLOSED];
        return;
    }
    
    int x = currentTemp-targetTemp;
    
    if (x > 2)
    {
        switch (currentVentState)
        {
            case VENT_CLOSED:
                NSLog(@"%d: setting to half\n", x);
                [self setVentStateForRoom:roomId toState:VENT_HALF];
                break;
            case VENT_HALF:
                NSLog(@"%d: setting to open\n", x);
                [self setVentStateForRoom:roomId toState:VENT_OPEN];
                break;
            default:
                break;
        }
    }
    else if (x < -2)
    {
        switch (currentVentState)
        {
            case VENT_OPEN:
                NSLog(@"%d: setting to half\n", x);
                [self setVentStateForRoom:roomId toState:VENT_HALF];
                break;
            case VENT_HALF:
                NSLog(@"%d: setting to closed\n", x);
                [self setVentStateForRoom:roomId toState:VENT_CLOSED];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (currentVentState) {
            case VENT_OPEN:
                NSLog(@"%d: setting to half\n", x);
                [self setVentStateForRoom:roomId toState:VENT_HALF];
                break;
            case VENT_CLOSED:
                NSLog(@"%d: setting to half\n", x);
                [self setVentStateForRoom:roomId toState:VENT_HALF];
                break;
            default:
                break;
        }
    }
}

-(void)changeOccurredForRoom:(int)roomId {
    [self updateHouseTemp];
    [self.RoomTableView reloadData];
    if (roomId == self.ActiveRoom) {
        self.RoomTemp.text = [NSString stringWithFormat:@"%@", [self.Temps objectAtIndex:roomId]];
        [self.RoomTemp setNeedsDisplay];
    }

    // Determine changes required to vent state
    [self checkVentStateForRoom:roomId];
}

-(void)changeOccurredForAllRooms {
    for (int i=0; i < [self.Rooms count]; i++) {
        [self changeOccurredForRoom:i];
    }
}

-(void)queryForRoom:(int)roomId {
    NSString *urlString = [NSString stringWithFormat:@"%@query.php?room=%@", SERVER_URL, [[self.Rooms objectAtIndex:roomId] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSLog(@"%@", urlString);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

//    NSString *post = [NSString stringWithFormat:@"room=%d", roomId];
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding                            allowLossyConversion:YES];
//	
//    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://obycode.com/smartventure/query.php"]];

    // Specify that it will be a POST request
//    request.HTTPMethod = @"POST";
    
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//	[request setHTTPBody:postData];
	
    NSURLResponse *response;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if (err) {
        NSLog(@"%@", [err localizedDescription]);
    }
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableContainers error: &err];
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", err);
    }
    
    NSDictionary *room = (NSDictionary *)jsonArray;
    int temp = [[room valueForKey:@"temp"] intValue];
    float tempF = (float) temp;
    tempF = temp * 9.0 / 5.0 + 32;
    temp = (int)tempF;
    int diff = abs(temp - [[self.Temps objectAtIndex:roomId] intValue]);
    // ignore strange values after motor moves
    if (diff > 10)
        return;
    if (temp != [[self.Temps objectAtIndex:roomId] intValue]) {
        [self.Temps replaceObjectAtIndex:roomId withObject:[NSNumber numberWithInt:temp]];
        [self changeOccurredForRoom:roomId];
    }
}

-(void)pollMainMethod {
    while(1) {
        [self queryForRoom:0];
        [NSThread sleepForTimeInterval:5.0f];
    }
}

    - (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.RoomView.hidden = YES;
    self.ActiveRoom = 0;
//    [self.OffButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [self.OffButton setTitle:@"ON" forState:UIControlStateSelected];
    
    // Pull data from server!
    self.Rooms = [NSMutableArray array];
    self.Temps = [NSMutableArray array];
    self.SetTemps = [NSMutableArray array];
    self.States = [NSMutableArray array];
    
    // Living Room
    [self.Rooms addObject:@"Living Room"];
    [self.Temps addObject:[NSNumber numberWithInt:73]];
    [self.SetTemps addObject:[NSNumber numberWithInt:73]];
    [self.States addObject:[NSNumber numberWithInt:50]];
    // Kitchen
    [self.Rooms addObject:@"Kitchen"];
    [self.Temps addObject:[NSNumber numberWithInt:71]];
    [self.SetTemps addObject:[NSNumber numberWithInt:72]];
    [self.States addObject:[NSNumber numberWithInt:50]];
    // Conference Room
    [self.Rooms addObject:@"Conference Room"];
    [self.Temps addObject:[NSNumber numberWithInt:70]];
    [self.SetTemps addObject:[NSNumber numberWithInt:70]];
    [self.States addObject:[NSNumber numberWithInt:50]];
    
    // Pull data once here before view
    [self queryForRoom:0];
    
    // Start polling thread
    [NSThread detachNewThreadSelector:@selector(pollMainMethod) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)homeBtnPressed:(UIButton *)sender {
    // Set "Home" mode
    if (self.HomeBtn.selected)
        self.HomeBtn.selected = false;
    else {
        self.HomeBtn.selected = true;
        self.AwayBtn.selected = false;
        self.NightBtn.selected = false;
        self.VacationBtn.selected = false;
        
        [self.SetTemps replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:72]];
        [self.SetTemps replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:72]];
        [self.SetTemps replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:72]];
        [self changeOccurredForAllRooms];
    }
}

- (IBAction)awayBtnPressed:(UIButton *)sender {
    // Set "Away" mode
    if (self.AwayBtn.selected)
        self.AwayBtn.selected = false;
    else {
        self.AwayBtn.selected = true;
        self.HomeBtn.selected = false;
        self.NightBtn.selected = false;
        self.VacationBtn.selected = false;
        
        
        [self.SetTemps replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:77]];
        [self.SetTemps replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:77]];
        [self.SetTemps replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:77]];
        [self changeOccurredForAllRooms];
    }
}

- (IBAction)nightBtnPressed:(UIButton *)sender {
    if (self.NightBtn.selected)
        self.NightBtn.selected = false;
    else {
        self.NightBtn.selected = true;
        self.HomeBtn.selected = false;
        self.AwayBtn.selected = false;
        self.VacationBtn.selected = false;
        
        [self.SetTemps replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:78]];
        [self.SetTemps replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:78]];
        [self.SetTemps replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:74]];
        [self changeOccurredForAllRooms];
    }
}

- (IBAction)VacationBtnPressed:(UIButton *)sender {
    if (self.VacationBtn.selected)
        self.VacationBtn.selected = false;
    else {
        self.HomeBtn.selected = false;
        self.AwayBtn.selected = false;
        self.NightBtn.selected = false;
        self.VacationBtn.selected = true;
        
        [self.SetTemps replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:84]];
        [self.SetTemps replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:84]];
        [self.SetTemps replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:84]];
        [self changeOccurredForAllRooms];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Room Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Room Cell"];
    }
    
    UILabel *label;

    // The Room name
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [self.Rooms objectAtIndex:indexPath.row];
        
    // The temp and target temp
    // Here, grab the saved target temp and query the curren temp
    label = (UILabel *)[cell viewWithTag:2];
    int setTemp = [[self.SetTemps objectAtIndex:indexPath.row] intValue];
    NSString *setTempStr;
    if (setTemp == 0)
        setTempStr = @"--";
    else
        setTempStr = [NSString stringWithFormat:@"%@", [self.SetTemps objectAtIndex:indexPath.row]];
    label.text = [NSString stringWithFormat:@"%@ : %@", setTempStr, [self.Temps objectAtIndex:indexPath.row]];

    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    self.ActiveRoom = indexPath.row;
    int setTempVal = [[self.SetTemps objectAtIndex:indexPath.row] intValue];
    if (setTempVal) {
        self.RoomSetTemp.text = [NSString stringWithFormat:@"%@", [self.SetTemps objectAtIndex:indexPath.row]];
        self.OffButton.selected = NO;
    }
    else {
        self.RoomSetTemp.text = @"--";
        self.OffButton.selected = YES;
    }
    self.RoomTemp.text = [NSString stringWithFormat:@"%@", [self.Temps objectAtIndex:indexPath.row]];
    
    int state = [[self.States objectAtIndex:indexPath.row] intValue];
    if (state == VENT_CLOSED)
        self.RoomVent.image = [UIImage imageNamed:@"Closed.png"];
    else if (state == VENT_HALF)
        self.RoomVent.image = [UIImage imageNamed:@"HalfOpen.png"];
    else
        self.RoomVent.image = [UIImage imageNamed:@"Open.png"];
    
    self.RoomView.hidden = NO;
}

- (IBAction)tempUpPressed:(id)sender {
    NSNumber *SetTemp = [self.SetTemps objectAtIndex:self.ActiveRoom];
    int value = [SetTemp intValue];
    // Handle off case
    if (value == 0) {
        value = 72;
        self.OffButton.selected = NO;
    }
    else
        value += 1;

    [self.SetTemps replaceObjectAtIndex:self.ActiveRoom withObject:[NSNumber numberWithInt:value]];
    self.RoomSetTemp.text = [NSString stringWithFormat:@"%d", value];

    [self changeOccurredForRoom:self.ActiveRoom];
    
    // If we were in a preset mode, disable it
    self.HomeBtn.selected = false;
    self.AwayBtn.selected = false;
    self.NightBtn.selected = false;
    self.VacationBtn.selected = false;
}

- (IBAction)tempDownPressed:(id)sender {
    NSNumber *SetTemp = [self.SetTemps objectAtIndex:self.ActiveRoom];
    int value = [SetTemp intValue];
    // Handle off case
    if (value == 0) {
        value = 72;
        self.OffButton.selected = NO;
    }
    else
        value -= 1;
    
    [self.SetTemps replaceObjectAtIndex:self.ActiveRoom withObject:[NSNumber numberWithInt:value]];
    self.RoomSetTemp.text = [NSString stringWithFormat:@"%d", value];
    
    [self changeOccurredForRoom:self.ActiveRoom];
    
    // If we were in a preset mode, disable it
    self.HomeBtn.selected = false;
    self.AwayBtn.selected = false;
    self.NightBtn.selected = false;
    self.VacationBtn.selected = false;
}

- (IBAction)offPressed:(UIButton *)sender {
    // Turning back on
    if (sender.selected) {
        [self.SetTemps replaceObjectAtIndex:self.ActiveRoom withObject:[NSNumber numberWithInt:72]];
        self.RoomSetTemp.text = @"72";
        sender.selected = NO;
    }
    else {
        // Turn it off
        [self.SetTemps replaceObjectAtIndex:self.ActiveRoom withObject:[NSNumber numberWithInt:0]];
        self.RoomSetTemp.text = @"--";
        sender.selected = YES;
    }
    [self changeOccurredForRoom:self.ActiveRoom];
    
    // If we were in a preset mode, disable it
    self.HomeBtn.selected = false;
    self.AwayBtn.selected = false;
    self.NightBtn.selected = false;
    self.VacationBtn.selected = false;
}

- (IBAction)doneBtnPressed:(UIButton *)sender {
    self.RoomView.hidden = YES;
}

@end
