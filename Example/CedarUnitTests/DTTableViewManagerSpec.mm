#import "DTTableViewManager.h"
#import <Foundation/Foundation.h>

using namespace Cedar::Matchers;

SPEC_BEGIN(DTTableViewManagerSpec)

describe(@"BaseTableViewController", ^{
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
    
    it(@"should set section titles", ^{
        [model setSectionHeaders:@[ TEST_1, TEST_2 ]];
        [model tableView:model.tableView titleForHeaderInSection:0] should equal(TEST_1);
        [model tableView:model.tableView titleForHeaderInSection:1] should equal(TEST_2);
    });
    
    it(@"should set section footers", ^{
        [model setSectionFooters:@[ TEST_1, TEST_2 ]];
        
        [model tableView:model.tableView titleForFooterInSection:0] should equal(TEST_1);
        [model tableView:model.tableView titleForFooterInSection:1] should equal(TEST_2);
    });
    
    it(@"should not raise exceptions", ^{
        [model addTableItem:testModel];
        [model addTableItem:testModel toSection:1];
        
        ^{
            [model tableView:model.tableView titleForFooterInSection:1];
            [model tableView:model.tableView titleForHeaderInSection:1];
            
        } should_not raise_exception;
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
    
    it(@"should return nil if table item not found", ^{
     
        [model addTableItems:@[acc2,testModel]];
        NSIndexPath * ip3 = [NSIndexPath indexPathForRow:6 inSection:3];
         NSIndexPath * testPath = [model indexPathOfTableItem:testModel];
        NSArray * tableItemsPaths = [model tableItemsArrayForIndexPaths:@[testPath, ip3]];
        
        tableItemsPaths should be_nil;
    });
    
    it(@"should move sections", ^{
        [model addTableItem:acc1];
        [model addTableItem:acc2 toSection:1];
        [model addTableItem:acc3 toSection:2];
        
        [model moveSection:0 toSection:1];
        
        NSArray * itemsSection0 = [model tableItemsInSection:0];
        [itemsSection0 lastObject] should equal(acc2);
        
        NSArray * itemsSection1 = [model tableItemsInSection:1];
        [itemsSection1 lastObject] should equal(acc1);
        
        [model moveSection:2 toSection:0];
        itemsSection0 = [model tableItemsInSection:0];
        [itemsSection0 lastObject] should equal(acc3);
        
        itemsSection1 = [model tableItemsInSection:1];
        [itemsSection1 lastObject] should equal(acc2);
        
        NSArray * itemsSection2 = [model tableItemsInSection:2];
        [itemsSection2 lastObject] should equal(acc1);
    });
    
    it(@"should delete sections", ^{
        [model addTableItem:acc1];
        [model addTableItem:acc2 toSection:1];
        [model addTableItem:acc3 toSection:2];
        
        [model deleteSections:[NSIndexSet indexSetWithIndex:1]];
        
        [model numberOfSections] should equal(2);
        
        NSArray * itemsSection1 = [model tableItemsInSection:1];
        [itemsSection1 lastObject] should equal(acc3);
    });
    
    it(@"should support all datasource methods", ^{
        [model respondsToSelector:@selector(tableView:
                                            commitEditingStyle:
                                            forRowAtIndexPath:)] should equal(YES);
        [model respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)] should equal(YES);
        [model respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] should equal(YES);
        [model respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)] should equal(YES);
    });
    
    it(@"should throw exception when delegate or datasource is not set", ^{
    
        UITableView * tableView = [[[UITableView alloc] init] autorelease];
        ^{
            [DTTableViewManager managerWithDelegate:nil andTableView:tableView];
        } should raise_exception;
        ^{
            [DTTableViewManager managerWithDelegate:model andTableView:nil];
        } should raise_exception;
        
    });
    
    it(@"should add non-repeating items", ^{
        [model addTableItems:@[acc1,acc2]];
        
        [model addNonRepeatingItems:@[acc1,acc3,acc2,acc4,acc5]
                          toSection:0
                   withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [model numberOfTableItemsInSection:0] should equal(5);
        NSArray * tableItems = [model tableItemsInSection:0];
        
        tableItems[0] should equal(acc1);
        tableItems[1] should equal(acc2);
        tableItems[2] should equal(acc3);
        tableItems[3] should equal(acc4);
        tableItems[4] should equal(acc5);
    });
});

SPEC_END
