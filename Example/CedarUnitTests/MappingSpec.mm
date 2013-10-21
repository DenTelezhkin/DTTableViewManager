#import "DTTableViewController.h"
#import "DTTableViewController+UnitTests.h"
#import <Foundation/Foundation.h>
#import "CellWithNib.h"
#import "CellWithoutNib.h"
#import "MockTableHeaderView.h"
#import "NiblessTableHeaderView.h"
#import "MockTableHeaderFooterView.h"
#import "NiblessTableHeaderFooterView.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(MappingSpecs)

describe(@"mapping tests", ^{
    
    
    [DTTableViewController setLogging:NO];
    
    describe(@"cell mapping from code", ^{
        
        __block DTTableViewController *model;
        __block Example * testModel;
        __block Example * acc1;
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.dataSource = model;
            model.tableView.delegate = model;
            testModel = [Example new];
            acc1 = [Example new];
            [model.tableView reloadData];
            
            [model registerCellClass:[CellWithoutNib class]
                       forModelClass:[Example class]];
            
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });
        
        it(@"should create cell from code", ^{
            
            [model addTableItem:acc1];
            
            [model verifyTableItem:acc1 atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            CellWithoutNib * cell = (CellWithoutNib *)[model.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            cell.awakedFromNib should_not be_truthy;
            cell.inittedWithStyle should be_truthy;
        });
        
        
    });
    
    describe(@"cell mapping from nib", ^{
        
        __block DTTableViewController *model;
        __block Example * testModel;
        __block Example * acc1;
        
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.delegate = model;
            model.tableView.dataSource = model;
            testModel = [Example new];
            acc1 = [Example new];
            
            [model.tableView reloadData];
            
            [model registerCellClass:[CellWithNib class]
                       forModelClass:[Example class]];
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });

        it(@"should create cell from nib", ^{
            
            [model addTableItem:acc1];
            
            [model verifyTableItem:acc1 atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            CellWithNib * cell = (CellWithNib *)[model.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            cell.awakedFromNib should be_truthy;
            cell.inittedWithStyle should_not be_truthy;
        });
        
        
    });
    
    describe(@"cell mapping should throw an exception, if no nib found", ^{
        __block DTTableViewController *model;
        __block Example * testModel;
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.delegate = model;
            model.tableView.dataSource = model;
            testModel = [Example new];
            
            [model.tableView reloadData];
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });
        
        it(@"should create cell from nib", ^{
            ^{
                [model registerNibNamed:@"NO-SUCH-NIB"
                           forCellClass:[ExampleCell class]
                             modelClass:[Example class]];
            } should raise_exception;
        });
    });
    
    describe(@"header/footer mapping", ^{
        
        __block DTTableViewController *model;
        __block Example * testModel;
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.delegate = model;
            model.tableView.dataSource = model;
            testModel = [Example new];
            
            [model.tableView reloadData];
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });
        
        it(@"should create header view from UIView", ^{
            [model registerHeaderClass:[MockTableHeaderView class]
                         forModelClass:[Example class]];
            
            [model.sectionHeaderModels addObject:[[Example new] autorelease]];
            
            UIView * headerView = [model tableView:model.tableView viewForHeaderInSection:0];
            
            [headerView isKindOfClass:[MockTableHeaderView class]] should BeTruthy();
        });
        
        it(@"should create footer view from UIView", ^{
           [model registerFooterClass:[MockTableHeaderView class]
                        forModelClass:[Example class]];
            
            [model.sectionFooterModels addObject:[[Example new] autorelease]];
            
            UIView * footerView = [model tableView:model.tableView viewForFooterInSection:0];
            
            [footerView isKindOfClass:[MockTableHeaderView class]] should BeTruthy();
        });
        
        it(@"should create header view from UITableViewHeaderFooterView", ^{
            if ([UITableViewHeaderFooterView class])
            {
                [model registerHeaderClass:[MockTableHeaderFooterView class]
                             forModelClass:[Example class]];
                
                [model.sectionHeaderModels addObject:[[Example new] autorelease]];
                
                UIView * headerView = [model tableView:model.tableView viewForHeaderInSection:0];
                
                [headerView isKindOfClass:[MockTableHeaderFooterView class]] should BeTruthy();
            }
        });
        
        it(@"should create footer view from UITableViewHeaderFooterView", ^{
            
            if ([UITableViewHeaderFooterView class])
            {
                [model registerFooterClass:[MockTableHeaderFooterView class]
                             forModelClass:[Example class]];
                
                [model.sectionFooterModels addObject:[[Example new] autorelease]];
                
                UIView * footerView = [model tableView:model.tableView viewForFooterInSection:0];
                
                [footerView isKindOfClass:[MockTableHeaderFooterView class]] should BeTruthy();
            }
        });
        
        it(@"should raise an exception when registering nibless header", ^{
           
            ^{
                [model registerHeaderClass:[NiblessTableHeaderView class]
                             forModelClass:[Example class]];
            } should raise_exception;
            
        });
        
        it(@"should raise an exception when registering nibless footer", ^{
            
            ^{
                [model registerFooterClass:[NiblessTableHeaderView class]
                             forModelClass:[Example class]];
            } should raise_exception;
            
        });
        
        it(@"should raise an exception when registering wrong nib for header", ^{
           
            ^{
                [model registerNibNamed:@"NO-SUCH-NIB"
                         forHeaderClass:[MockTableHeaderView class]
                             modelClass:[Example class]];
            } should raise_exception;
            
        });
        
        it(@"should raise an exception when registering wrong nib for footer", ^{
            ^{
                [model registerNibNamed:@"NO-SUCH-NIB"
                         forFooterClass:[MockTableHeaderView class]
                             modelClass:[Example class]];
            } should raise_exception;
        });
    });
    
});

describe(@"Foundation class clusters", ^{
    
    __block DTTableViewController *model;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        model = [DTTableViewController new];
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.dataSource = model;
        model.tableView.delegate = model;
        [model.tableView reloadData];
        
    });
    
    afterEach(^{
        [model release];
        [UIView setAnimationsEnabled:YES];
    });
    
    describe(@"NSString", ^{
       
        beforeEach(^{
            [model registerCellClass:[CellWithNib class]
                       forModelClass:[NSString class]];
            [model registerHeaderClass:[MockTableHeaderView class]
                         forModelClass:[NSString class]];
            [model registerFooterClass:[MockTableHeaderView class]
                         forModelClass:[NSString class]];
        });
        
        it(@"should accept constant strings", ^{
            ^{
                [model addTableItem:@""];
            } should_not raise_exception;
        });
        
        it(@"should accept non-empty strings", ^{
            ^{
                [model addTableItem:@"not empty"];
            } should_not raise_exception;
        });
        
        it(@"should accept mutable string", ^{
            ^{
                NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                [string appendString:@",second"];
                [model addTableItem:string];
            } should_not raise_exception;
        });
        
        it(@"should accept NSString header", ^{
            ^{
                [model.sectionHeaderModels addObject:@"foo"];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSString footer ", ^{
            ^{
                [model.sectionFooterModels addObject:@"bar"];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSMutableString", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSMutableString class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSMutableString class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSMutableString class]];
        });
        
        it(@"should accept constant strings", ^{
            ^{
                [model addTableItem:@""];
            } should_not raise_exception;
        });
        
        it(@"should accept non-empty strings", ^{
            ^{
                [model addTableItem:@"not empty"];
            } should_not raise_exception;
        });
        
        it(@"should accept mutable string", ^{
            ^{
                NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                [string appendString:@",second"];
                [model addTableItem:string];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableString header", ^{
            ^{
                [model.sectionHeaderModels addObject:@"foo"];
                [model tableView:model.tableView viewForHeaderInSection:0];

            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableString footer ", ^{
            ^{
                [model.sectionFooterModels addObject:@"bar"];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSNumber", ^{
       
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSNumber class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSNumber class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSNumber class]];
        });
        
        it(@"should accept nsnumber for cells", ^{
            ^{
                [model addTableItem:@5];
            } should_not raise_exception;
        });
        
        it(@"should accept bool number for cells", ^{
            ^{
                [model addTableItem:@YES];
            } should_not raise_exception;
        });
        
        it(@"should accept number for header", ^{
            ^{
                [model.sectionHeaderModels addObject:@5];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept number for footer", ^{
            ^{
                [model.sectionFooterModels addObject:@5];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept BOOL for header", ^{
            ^{
                [model.sectionHeaderModels addObject:@YES];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept bool for footer", ^{
            ^{
                [model.sectionFooterModels addObject:@YES];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSDictionary", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSDictionary class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSDictionary class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSDictionary class]];
        });
        
        it(@"should accept NSDictionary for cells", ^{
            ^{
                [model addTableItem:@{@1:@2}];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for cells", ^{
            ^{
                [model addTableItem:[[@{@1:@2} mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for header", ^{
            ^{
                [model.sectionHeaderModels addObject:@{}];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for footer", ^{
            ^{
                [model.sectionFooterModels addObject:@{}];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for header", ^{
            ^{
                [model.sectionHeaderModels addObject:[[@{} mutableCopy] autorelease]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for footer", ^{
            ^{
                [model.sectionFooterModels addObject:[[@{} mutableCopy] autorelease]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSMutableDictionary", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSMutableDictionary class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSMutableDictionary class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSMutableDictionary class]];
        });
        
        it(@"should accept NSDictionary for cells", ^{
            ^{
                [model addTableItem:@{@1:@2}];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for cells", ^{
            ^{
                [model addTableItem:[[@{@1:@2} mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for header", ^{
            ^{
                [model.sectionHeaderModels addObject:@{}];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for footer", ^{
            ^{
                [model.sectionFooterModels addObject:@{}];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for header", ^{
            ^{
                [model.sectionHeaderModels addObject:[[@{} mutableCopy] autorelease]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for footer", ^{
            ^{
                [model.sectionFooterModels addObject:[[@{} mutableCopy] autorelease]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSArray", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSArray class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSArray class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSArray class]];
        });
        
        it(@"should accept NSArray for cells", ^{
            ^{
                [model addTableItem:@[]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for cells", ^{
            ^{
                [model addTableItem:[[@[] mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for header", ^{
            ^{
                [model.sectionHeaderModels addObject:@[]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for header", ^{
            ^{
                [model.sectionHeaderModels addObject:[[@[] mutableCopy] autorelease]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for footer", ^{
            ^{
                [model.sectionFooterModels addObject:@[]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for footer", ^{
            ^{
                [model.sectionFooterModels addObject:[[@[] mutableCopy] autorelease]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
    });
    
    describe(@"NSMutableArray", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSMutableArray class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSMutableArray class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSMutableArray class]];
        });
        
        it(@"should accept NSArray for cells", ^{
            ^{
                [model addTableItem:@[]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for cells", ^{
            ^{
                [model addTableItem:[[@[] mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for header", ^{
            ^{
                [model.sectionHeaderModels addObject:@[]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for header", ^{
            ^{
                [model.sectionHeaderModels addObject:[[@[] mutableCopy] autorelease]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for footer", ^{
            ^{
                [model.sectionFooterModels addObject:@[]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for footer", ^{
            ^{
                [model.sectionFooterModels addObject:[[@[] mutableCopy] autorelease]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
    });
});

SPEC_END
