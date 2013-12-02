#import "DTTableViewController.h"
#import "DTTableViewController+UnitTests.h"
#import "DTTableViewMemoryStorage.h"
#import "DTTableViewMemoryStorage+UnitTests.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(DatasourceSpecs)

describe(@"Datasource spec", ^{
    __block DTTableViewController *model;
    __block DTTableViewMemoryStorage * storage;
    __block Example * testModel;
    __block Example * acc1;
    __block Example * acc2;
    __block Example * acc3;
    __block Example * acc4;
    __block Example * acc5;
    __block Example * acc6;
    
    [DTTableViewController setLogging:NO];
    
    beforeEach(^{
        [UIView setAnimationsEnabled:NO];
        
        model = [DTTableViewController new];
        storage = [DTTableViewMemoryStorage storageWithDelegate:model];
        model.dataStorage = storage;
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        [model registerCellClass:[ExampleCell class] forModelClass:[Example class]];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        [model.tableView reloadData];
        testModel = [Example new];
        acc1 = [[Example new] autorelease];
        acc2 = [[Example new] autorelease];
        acc3 = [[Example new] autorelease];
        acc4 = [[Example new] autorelease];
        acc5 = [[Example new] autorelease];
        acc6 = [[Example new] autorelease];
    });
    
    afterEach(^{
        [model release];
        [testModel release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
#define TEST_1 @"test1"
#define TEST_2 @"test2"
    
    it(@"should return correct tableItem", ^{
        [storage addTableItems:@[acc3,acc2,acc1,acc6,acc4]];
        
        [model verifyTableItem:acc6
                   atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should be_truthy;
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;

        [storage tableItemAtIndexPath:[NSIndexPath indexPathForRow:56 inSection:0]] should be_nil;
    });
    
    it(@"should return correct indexPath", ^{
        [storage addTableItems:@[acc3,acc2,acc1,acc6,acc4]];
        
        [storage indexPathOfTableItem:acc2] should equal([NSIndexPath indexPathForRow:1 inSection:0]);
        
        [storage indexPathOfTableItem:acc4] should equal([NSIndexPath indexPathForRow:4 inSection:0]);
        
        [storage indexPathOfTableItem:acc5] should be_nil;
    });
    
    it(@"should correctly map index paths to models", ^{
        
        NSArray * testArray1 = @[ acc1, testModel, acc3 ];
        [storage addTableItems:testArray1];
        
        NSArray * testArray2 = @[ acc6, acc4, testModel ];
        [storage addTableItems:testArray2 toSection:1];
        
        NSArray * testArray3 = @[ testModel, acc5, acc2 ];
        [storage addTableItems:testArray3 toSection:2];
        
        NSIndexPath * ip1 = [storage indexPathOfTableItem:acc1];
        NSIndexPath * ip2 = [storage indexPathOfTableItem:acc2];
        NSIndexPath * ip3 = [storage indexPathOfTableItem:acc3];
        NSIndexPath * ip4 = [storage indexPathOfTableItem:acc4];
        NSIndexPath * ip5 = [storage indexPathOfTableItem:acc5];
        NSIndexPath * ip6 = [storage indexPathOfTableItem:acc6];
        NSIndexPath * testPath = [storage indexPathOfTableItem:testModel];
        
        NSArray * indexPaths = [storage indexPathArrayForTableItems:testArray1];
        
        [indexPaths objectAtIndex:0] should equal(ip1);
        [indexPaths objectAtIndex:1] should equal(testPath);
        [indexPaths objectAtIndex:2] should equal(ip3);
        
        indexPaths = [storage indexPathArrayForTableItems:testArray2];
        [indexPaths objectAtIndex:0] should equal(ip6);
        [indexPaths objectAtIndex:1] should equal(ip4);
        [indexPaths objectAtIndex:2] should equal(testPath);
        
        indexPaths = [storage indexPathArrayForTableItems:testArray3];
        [indexPaths objectAtIndex:0] should equal(testPath);
        [indexPaths objectAtIndex:1] should equal(ip5);
        [indexPaths objectAtIndex:2] should equal(ip2);
    });
    
    it(@"should return correct number of table items", ^{
        [storage addTableItem:testModel];
        [storage addTableItem:testModel];
        [storage addTableItem:testModel];
        [storage addTableItem:testModel];
        
        [storage addTableItem:testModel toSection:1];
        [storage addTableItem:testModel toSection:1];
        [storage addTableItem:testModel toSection:1];
        
        [[storage tableItemsInSection:0] count] should equal(4);
        [[storage tableItemsInSection:1] count] should equal(3);
        
        [model tableView:model.tableView numberOfRowsInSection:0] should equal(4);
        [model tableView:model.tableView numberOfRowsInSection:1] should equal(3);
    });
    
    it(@"should return correct number of sections", ^{
        [storage addTableItem:acc1 toSection:0];
        [storage addTableItem:acc4 toSection:3];
        [storage addTableItem:acc2 toSection:2];
        
        [model numberOfSectionsInTableView:model.tableView] should equal(4);
    });
    
    it(@"should set section titles", ^{
        model.sectionHeaderStyle = DTTableViewSectionStyleTitle;
        [storage setSectionHeaderTitles:[@[ TEST_1, TEST_2 ] mutableCopy]];
        [model tableView:model.tableView titleForHeaderInSection:0] should equal(TEST_1);
        [model tableView:model.tableView titleForHeaderInSection:1] should equal(TEST_2);
    });
    
    it(@"should set section footers", ^{
        model.sectionFooterStyle = DTTableViewSectionStyleTitle;
        [storage setSectionFooterTitles:[@[ TEST_1, TEST_2 ] mutableCopy]];
        
        [model tableView:model.tableView titleForFooterInSection:0] should equal(TEST_1);
        [model tableView:model.tableView titleForFooterInSection:1] should equal(TEST_2);
    });
    
    it(@"should handle titles and footers", ^{
        [storage addTableItem:testModel];
        [storage addTableItem:testModel toSection:1];
        
        ^{
            [model tableView:model.tableView titleForFooterInSection:1];
            [model tableView:model.tableView titleForHeaderInSection:1];
            
        } should_not raise_exception;
    });
    
    it(@"should add table item", ^{
        [storage addTableItem:acc1];
        [storage addTableItem:acc4];
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc4
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should add table items", ^{
        [storage addTableItems:@[acc3,acc2]];
        [storage tableItemsInSection:0].count should equal(2);
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should add table item to section", ^{
        [storage addTableItem:acc1 toSection:0];
        [storage addTableItem:acc2 toSection:2];
        [storage addTableItem:acc4 toSection:2];
        
        [[storage sections] count] should equal(3);
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] should be_truthy;
        [model verifyTableItem:acc4
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] should be_truthy;
    });
    
    it(@"should add table items to section", ^{
        [storage addTableItems:@[acc1,acc3,acc5] toSection:4];
        
        [[storage sections] count] should equal(5);
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:4]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:4]] should be_truthy;
    });
    
    it(@"should add table item withRowAnimation", ^{
        [storage addTableItem:acc2];
        [storage addTableItem:acc5];
        
        [[storage tableItemsInSection:0] count] should equal(2);
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should add table items  with row animation",^{
        [storage addTableItems:@[acc3,acc5,acc2]];
        
        [[storage tableItemsInSection:0] count] should equal(3);
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
    });
    
    it(@"should insert table item to indexPath", ^{
        [storage addTableItems:@[acc2,acc4,acc6]];
        [storage insertTableItem:acc1 toIndexPath:[storage indexPathOfTableItem:acc2]];
        [storage insertTableItem:acc3 toIndexPath:[storage indexPathOfTableItem:acc4]];
        
        [[storage tableItemsInSection:0] count] should equal(5);
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
    });
    
    it(@"should insert table item to indexPath with row animation", ^{
        [storage addTableItems:@[acc2,acc4,acc6]];
        [storage insertTableItem:acc1
                   toIndexPath:[storage indexPathOfTableItem:acc2]];
        [storage insertTableItem:acc3
                   toIndexPath:[storage indexPathOfTableItem:acc4]];
        
        [[storage tableItemsInSection:0] count] should equal(5);
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
    });
    
    it(@"should replace table item with tableItem", ^{
        [storage addTableItems:@[acc1,acc3]];
        [storage addTableItems:@[acc4,acc6] toSection:1];
        
        [storage replaceTableItem:acc3 withTableItem:acc2];
        [storage replaceTableItem:acc4 withTableItem:acc5];
        
        [[storage tableItemsInSection:0] count] should equal(2);
        [[storage tableItemsInSection:1] count] should equal(2);
       
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should do nothing if trying to replace nil items", ^{
        [storage addTableItems:@[acc1,acc3,acc5]];
        ^{
            [storage replaceTableItem:nil withTableItem:acc2];
            [storage replaceTableItem:acc5 withTableItem:nil];
        } should_not raise_exception;
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
        
        [[storage tableItemsInSection:0] count] should equal(3);
    });
    
    it(@"should replace table item with tableItem with row animation", ^{
        [storage addTableItems:@[acc1,acc3]];
        [storage addTableItems:@[acc4,acc6] toSection:1];
        
        [storage replaceTableItem:acc3 withTableItem:acc2];
        [storage replaceTableItem:acc4 withTableItem:acc5];
        
        [[storage tableItemsInSection:0] count] should equal(2);
        [[storage tableItemsInSection:1] count] should equal(2);
        
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should do nothing if trying to replace nil items with row animation", ^{
        [storage addTableItems:@[acc1,acc3,acc5]];
        ^{
            [storage replaceTableItem:nil withTableItem:acc2];
            [storage replaceTableItem:acc5 withTableItem:nil];
        } should_not raise_exception;
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
        [[storage tableItemsInSection:0] count] should equal(3);
    });
    
    it(@"should remove table item", ^{
        [storage addTableItems:@[acc3,acc1,acc2,acc4,acc5]];
        
        [storage removeTableItem:acc4];
        [storage removeTableItem:acc3];
        [storage removeTableItem:acc5];
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should remove table items", ^{
        [storage addTableItems:@[acc1,acc3,acc2,acc4]];
        [storage removeTableItems:@[acc1,acc4,acc3,acc5]];
        [[storage tableItemsInSection:0] count] should equal(1);
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
    });
    
    it(@"should remove all table items", ^{
        [storage addTableItems:@[acc1,acc5,acc4,acc2]];
        [storage removeAllTableItems];
        
        [[storage tableItemsInSection:0] count] should equal(0);
    });
    
    it(@"should move sections", ^{
        [storage addTableItem:acc1];
        [storage addTableItem:acc2 toSection:1];
        [storage addTableItem:acc3 toSection:2];
        
        [storage moveSection:0 toSection:1];
        
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
        
        [storage moveSection:2 toSection:0];
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;

        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;

        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] should be_truthy;
    });
    
    it(@"should delete sections", ^{
        [storage addTableItem:acc1];
        [storage addTableItem:acc2 toSection:1];
        [storage addTableItem:acc3 toSection:2];
        
        [storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
        
        [[storage sections] count] should equal(2);
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should delete sections with row animation", ^{
        [storage addTableItem:acc1];
        [storage addTableItem:acc2 toSection:1];
        [storage addTableItem:acc3 toSection:2];
        
        [storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
        
        [[storage sections] count] should equal(2);
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should not throw exception if inserting at illegal indexPath", ^{
        ^{
            [storage insertTableItem:acc1 toIndexPath:
             [NSIndexPath indexPathForRow:1 inSection:0]];
        } should_not raise_exception;
    });
    
    it(@"should not throw exception if inserting at illegal indexPath", ^{
        ^{
            [storage insertTableItem:acc1 toIndexPath:
             [NSIndexPath indexPathForRow:3 inSection:5]];
        } should_not raise_exception;
    });

});

SPEC_END
