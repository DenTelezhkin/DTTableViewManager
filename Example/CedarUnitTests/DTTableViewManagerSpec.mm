#import "DTTableViewManager.h"
#import "DTTableViewManager+UnitTests.h"
#import <Foundation/Foundation.h>

using namespace Cedar::Matchers;

SPEC_BEGIN(DTTableViewManagerSpec)

describe(@"Datasource spec", ^{
    __block DTTableViewManager *model;
    __block Example * testModel;
    __block Example * acc1;
    __block Example * acc2;
    __block Example * acc3;
    __block Example * acc4;
    __block Example * acc5;
    __block Example * acc6;
    
    
    beforeEach(^{
        model = [DTTableViewManager new];
        [model setClassMappingforCellClass:[ExampleCell class] modelClass:[Example class]];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
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
    });
    
#define TEST_1 @"test1"
#define TEST_2 @"test2"
    
    it(@"should raise exception on init with invalid tableView", ^{
        ^{
            [DTTableViewManager managerWithDelegate:model andTableView:nil];
        } should raise_exception;
    });
    
    it(@"should return correct tableItem", ^{
        [model addTableItems:@[acc3,acc2,acc1,acc6,acc4]];
        
        [model verifyTableItem:acc6
                   atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should be_truthy;
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] should be_truthy;

        [model tableItemAtIndexPath:[NSIndexPath indexPathForRow:56 inSection:0]] should be_nil;
    });
    
    it(@"should return correct indexPath", ^{
        [model addTableItems:@[acc3,acc2,acc1,acc6,acc4]];
        
        [model indexPathOfTableItem:acc2] should equal([NSIndexPath indexPathForRow:1 inSection:0]);
        
        [model indexPathOfTableItem:acc4] should equal([NSIndexPath indexPathForRow:4 inSection:0]);
        
        [model indexPathOfTableItem:acc5] should be_nil;
    });
    
    it(@"should correctly map index paths to models", ^{
        
        NSArray * testArray1 = @[ acc1, testModel, acc3 ];
        [model addTableItems:testArray1];
        
        NSArray * testArray2 = @[ acc6, acc4, testModel ];
        [model addTableItems:testArray2 toSection:1];
        
        NSArray * testArray3 = @[ testModel, acc5, acc2 ];
        [model addTableItems:testArray3 toSection:2];
        
        NSIndexPath * ip1 = [model indexPathOfTableItem:acc1];
        NSIndexPath * ip2 = [model indexPathOfTableItem:acc2];
        NSIndexPath * ip3 = [model indexPathOfTableItem:acc3];
        NSIndexPath * ip4 = [model indexPathOfTableItem:acc4];
        NSIndexPath * ip5 = [model indexPathOfTableItem:acc5];
        NSIndexPath * ip6 = [model indexPathOfTableItem:acc6];
        NSIndexPath * testPath = [model indexPathOfTableItem:testModel];
        
        NSArray * indexPaths = [model indexPathArrayForTableItems:testArray1];
        
        [indexPaths objectAtIndex:0] should equal(ip1);
        [indexPaths objectAtIndex:1] should equal(testPath);
        [indexPaths objectAtIndex:2] should equal(ip3);
        
        indexPaths = [model indexPathArrayForTableItems:testArray2];
        [indexPaths objectAtIndex:0] should equal(ip6);
        [indexPaths objectAtIndex:1] should equal(ip4);
        [indexPaths objectAtIndex:2] should equal(testPath);
        
        indexPaths = [model indexPathArrayForTableItems:testArray3];
        [indexPaths objectAtIndex:0] should equal(testPath);
        [indexPaths objectAtIndex:1] should equal(ip5);
        [indexPaths objectAtIndex:2] should equal(ip2);
    });
    
    it(@"should return table items array", ^{
        [model addTableItems:@[acc1,acc3,acc2,testModel]];
        
        NSIndexPath * ip1 = [model indexPathOfTableItem:acc1];
        NSIndexPath * ip3 = [model indexPathOfTableItem:acc3];
        NSIndexPath * testPath = [model indexPathOfTableItem:testModel];
        
        NSArray * tableItemsPaths = [model tableItemsArrayForIndexPaths:@[ip1,testPath,ip3]];
        
        [tableItemsPaths objectAtIndex:0] should equal(acc1);
        [tableItemsPaths objectAtIndex:1] should equal(testModel);
        [tableItemsPaths objectAtIndex:2] should equal(acc3);
    });
    
    it(@"should return NSNull if table item not found", ^{
        
        [model addTableItems:@[acc2,testModel]];
        NSIndexPath * ip3 = [NSIndexPath indexPathForRow:6 inSection:3];
        NSIndexPath * testPath = [model indexPathOfTableItem:testModel];
        NSArray * tableItemsPaths = [model tableItemsArrayForIndexPaths:@[testPath, ip3]];
        
        tableItemsPaths[0] should equal(testModel);
        tableItemsPaths[1] should equal([NSNull null]);
    });
    
    it(@"should return correct number of table items", ^{
        [model addTableItem:testModel];
        [model addTableItem:testModel];
        [model addTableItem:testModel];
        [model addTableItem:testModel];
        
        [model addTableItem:testModel toSection:1];
        [model addTableItem:testModel toSection:1];
        [model addTableItem:testModel toSection:1];
        
        [model numberOfTableItemsInSection:0] should equal(4);
        [model numberOfTableItemsInSection:1] should equal(3);
        [model tableView:model.tableView numberOfRowsInSection:0] should equal(4);
        [model tableView:model.tableView numberOfRowsInSection:1] should equal(3);
    });
    
    it(@"should return correct number of sections", ^{
        [model addTableItem:acc1 toSection:0];
        [model addTableItem:acc4 toSection:3];
        [model addTableItem:acc2 toSection:2];
        
        [model numberOfSections] should equal(4);
        [model numberOfSectionsInTableView:model.tableView] should equal(4);
    });
    
    it(@"should set section titles", ^{
        [model setSectionHeaderTitles:@[ TEST_1, TEST_2 ]];
        [model tableView:model.tableView titleForHeaderInSection:0] should equal(TEST_1);
        [model tableView:model.tableView titleForHeaderInSection:1] should equal(TEST_2);
    });
    
    it(@"should set section footers", ^{
        [model setSectionFooterTitles:@[ TEST_1, TEST_2 ]];
        
        [model tableView:model.tableView titleForFooterInSection:0] should equal(TEST_1);
        [model tableView:model.tableView titleForFooterInSection:1] should equal(TEST_2);
    });
    
    it(@"should handle titles and footers", ^{
        [model addTableItem:testModel];
        [model addTableItem:testModel toSection:1];
        
        ^{
            [model tableView:model.tableView titleForFooterInSection:1];
            [model tableView:model.tableView titleForHeaderInSection:1];
            
        } should_not raise_exception;
    });
    
    it(@"should add table item", ^{
        [model addTableItem:acc1];
        [model addTableItem:acc4];
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc4
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should add table items", ^{
        [model addTableItems:@[acc3,acc2]];
        [model tableItemsInSection:0].count should equal(2);
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should add table item to section", ^{
        [model addTableItem:acc1 toSection:0];
        [model addTableItem:acc2 toSection:2];
        [model addTableItem:acc4 toSection:2];
        
        [model numberOfSections] should equal(3);
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] should be_truthy;
        [model verifyTableItem:acc4
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] should be_truthy;
    });
    
    it(@"should add table items to section", ^{
        [model addTableItems:@[acc1,acc3,acc5] toSection:4];
        
        [model numberOfSections] should equal(5);
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:4]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:4]] should be_truthy;
    });
    
    it(@"should add table item withRowAnimation", ^{
        [model addTableItem:acc2 withRowAnimation:UITableViewRowAnimationNone];
        [model addTableItem:acc5 withRowAnimation:UITableViewRowAnimationNone];
        
        [model numberOfTableItemsInSection:0] should equal(2);
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should add table items  with row animation",^{
        [model addTableItems:@[acc3,acc5,acc2] withRowAnimation:UITableViewRowAnimationNone];
        
        [model numberOfTableItemsInSection:0] should equal(3);
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
    });
    
    it(@"should add non-repeating items", ^{
        [model addTableItems:@[acc1,acc2]];
        
        [model addNonRepeatingItems:@[acc1,acc3,acc2,acc4,acc5]
                          toSection:0
                   withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [model numberOfTableItemsInSection:0] should equal(5);
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
        [model verifyTableItem:acc4
                   atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]] should be_truthy;
    });
    
    it(@"should insert table item to indexPath", ^{
        [model addTableItems:@[acc2,acc4,acc6]];
        [model insertTableItem:acc1 toIndexPath:[model indexPathOfTableItem:acc2]];
        [model insertTableItem:acc3 toIndexPath:[model indexPathOfTableItem:acc4]];
        
        [model numberOfTableItemsInSection:0] should equal(5);
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
    });
    
    it(@"should insert table item to indexPath with row animation", ^{
        [model addTableItems:@[acc2,acc4,acc6]];
        [model insertTableItem:acc1
                   toIndexPath:[model indexPathOfTableItem:acc2]
              withRowAnimation:UITableViewRowAnimationNone];
        [model insertTableItem:acc3
                   toIndexPath:[model indexPathOfTableItem:acc4]
              withRowAnimation:UITableViewRowAnimationNone];
        
        [model numberOfTableItemsInSection:0] should equal(5);
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
    });
    
    it(@"should replace table item with tableItem", ^{
        [model addTableItems:@[acc1,acc3]];
        [model addTableItems:@[acc4,acc6] toSection:1];
        
        [model replaceTableItem:acc3 withTableItem:acc2];
        [model replaceTableItem:acc4 withTableItem:acc5];
        
        [model numberOfTableItemsInSection:0] should equal(2);
        [model numberOfTableItemsInSection:1] should equal(2);
       
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should do nothing if trying to replace nil items", ^{
        [model addTableItems:@[acc1,acc3,acc5]];
        ^{
            [model replaceTableItem:nil withTableItem:acc2];
            [model replaceTableItem:acc5 withTableItem:nil];
        } should_not raise_exception;
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
        
        [model numberOfTableItemsInSection:0] should equal(3);
    });
    
    it(@"should replace table item with tableItem with row animation", ^{
        [model addTableItems:@[acc1,acc3]];
        [model addTableItems:@[acc4,acc6] toSection:1];
        
        [model replaceTableItem:acc3 withTableItem:acc2 andRowAnimation:UITableViewRowAnimationNone];
        [model replaceTableItem:acc4 withTableItem:acc5 andRowAnimation:UITableViewRowAnimationNone];
        
        [model numberOfTableItemsInSection:0] should equal(2);
        [model numberOfTableItemsInSection:1] should equal(2);
        
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should do nothing if trying to replace nil items with row animation", ^{
        [model addTableItems:@[acc1,acc3,acc5]];
        ^{
            [model replaceTableItem:nil withTableItem:acc2 andRowAnimation:UITableViewRowAnimationNone];
            [model replaceTableItem:acc5 withTableItem:nil andRowAnimation:UITableViewRowAnimationNone];
        } should_not raise_exception;
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
        [model verifyTableItem:acc5
                   atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should be_truthy;
        [[model tableItemsInSection:0] count] should equal(3);
    });
    
    it(@"should remove table item", ^{
        [model addTableItems:@[acc3,acc1,acc2,acc4,acc5]];
        
        [model removeTableItem:acc4];
        [model removeTableItem:acc3];
        [model removeTableItem:acc5];
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should remove table items with row animation", ^{
        [model addTableItems:@[acc3,acc1,acc2,acc4,acc5]];
        
        [model removeTableItem:acc4 withRowAnimation:UITableViewRowAnimationNone];
        [model removeTableItem:acc3 withRowAnimation:UITableViewRowAnimationNone];
        [model removeTableItem:acc5 withRowAnimation:UITableViewRowAnimationNone];
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_truthy;
    });
    
    it(@"should remove table items", ^{
        [model addTableItems:@[acc1,acc3,acc2,acc4]];
        [model removeTableItems:@[acc1,acc4,acc3,acc5]];
        [[model tableItemsInSection:0] count] should equal(1);
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
    });
    
    it(@"should remove table items with row animation", ^{
        [model addTableItems:@[acc1,acc3,acc2,acc4]];
        [model removeTableItems:@[acc1,acc4,acc3,acc5]
               withRowAnimation:UITableViewRowAnimationNone];
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        [[model tableItemsInSection:0] count] should equal(1);
    });
    
    it(@"should remove all table items", ^{
        [model addTableItems:@[acc1,acc5,acc4,acc2]];
        [model removeAllTableItems];
        
        [[model tableItemsInSection:0] count] should equal(0);
    });
    
    it(@"should move sections", ^{
        [model addTableItem:acc1];
        [model addTableItem:acc2 toSection:1];
        [model addTableItem:acc3 toSection:2];
        
        [model moveSection:0 toSection:1];
        
        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
        
        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
        
        [model moveSection:2 toSection:0];
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;

        [model verifyTableItem:acc2
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;

        [model verifyTableItem:acc1
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] should be_truthy;
    });
    
    it(@"should delete sections", ^{
        [model addTableItem:acc1];
        [model addTableItem:acc2 toSection:1];
        [model addTableItem:acc3 toSection:2];
        
        [model deleteSections:[NSIndexSet indexSetWithIndex:1]];
        
        [model numberOfSections] should equal(2);
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should delete sections with row animation", ^{
        [model addTableItem:acc1];
        [model addTableItem:acc2 toSection:1];
        [model addTableItem:acc3 toSection:2];
        
        [model deleteSections:[NSIndexSet indexSetWithIndex:1]
             withRowAnimation:UITableViewRowAnimationNone];
        
        [model numberOfSections] should equal(2);
        
        [model verifyTableItem:acc3
                   atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should be_truthy;
    });
    
    it(@"should reload sections", ^{
        id tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
        UITableView * temp = model.tableView;
        model.tableView = tableViewMock;
        NSIndexSet * iSet = [NSIndexSet indexSetWithIndex:3];
        
        [[tableViewMock expect] reloadSections:iSet withRowAnimation:UITableViewRowAnimationNone];
        
        [model reloadSections:iSet withRowAnimation:UITableViewRowAnimationNone];
        
        [tableViewMock verify];
        
        model.tableView = temp;
    });
    
    
    it(@"should support all datasource methods", ^{
        [model respondsToSelector:@selector(tableView:
                                            commitEditingStyle:
                                            forRowAtIndexPath:)] should equal(YES);
        [model respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)] should equal(YES);
        [model respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] should equal(YES);
        [model respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)] should equal(YES);
    });
    
    it(@"should not throw exception if inserting at illegal indexPath", ^{
        ^{
            [model insertTableItem:acc1 toIndexPath:
             [NSIndexPath indexPathForRow:1 inSection:0]];
        } should_not raise_exception;
    });
    
    it(@"should not throw exception if inserting at illegal indexPath", ^{
        ^{
            [model insertTableItem:acc1 toIndexPath:
             [NSIndexPath indexPathForRow:3 inSection:5]];
        } should_not raise_exception;
    });

});

SPEC_END
