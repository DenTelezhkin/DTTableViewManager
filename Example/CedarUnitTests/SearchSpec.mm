#import "DTTableViewController.h"
#import "MockTableHeaderFooterView.h"
#import "DTTableViewMemoryStorage.h"
#import "DTTableViewController+UnitTests.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SearchSpec)

__block DTTableViewController *model;
__block Example * acc1;
__block Example * acc2;
__block Example * acc3;
__block Example * acc4;
__block Example * acc5;
__block Example * acc6;
__block Example * testModel;
__block DTTableViewMemoryStorage * storage;


[DTTableViewController setLogging:NO];

describe(@"search in first section", ^{
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        model = [DTTableViewController new];
        
        storage = [DTTableViewMemoryStorage storageWithDelegate:model];
        model.dataStorage = storage;
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        [model registerCellClass:[ExampleCell class] forModelClass:[Example class]];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [storage addTableItems:@[acc1,acc2,acc3,acc4,acc5,acc6]];
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should find 2 items with double s", ^{
        [model filterTableItemsForSearchString:@"ss"];
        
        [model tableView:model.tableView numberOfRowsInSection:0] should equal(2);
        
        [model verifyTableItem:acc6 atIndexPath:[NSIndexPath indexPathForRow:1
                                                                   inSection:0]];
    });
    
    it(@"should find none items for iva", ^{
        [model filterTableItemsForSearchString:@"iva"];
        
        expect([model numberOfSectionsInTableView:model.tableView]).to(equal(0));
    });
    
    it(@"should find 1 item for cow", ^{
        [model filterTableItemsForSearchString:@"cow"];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(1));
        
        [model verifyTableItem:acc4 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
    });
    
    it(@"should find 1 item for white space", ^{
        [model filterTableItemsForSearchString:@" "];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(1));
        
        [model verifyTableItem:acc5 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
    });
    
    it(@"should find 1 item for .", ^{
        [model filterTableItemsForSearchString:@"."];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(1));
        
        [model verifyTableItem:acc5 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
    });
    
    it(@"should find all items for empty search string", ^{
        [model filterTableItemsForSearchString:@"."];
        
        [model filterTableItemsForSearchString:@""];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(6));
    });
    
    it(@"should find rai items", ^{
        [model filterTableItemsForSearchString:@"rai"];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(1));
    });
    
    
});

describe(@"search in multiple sections", ^{
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        model = [DTTableViewController new];
        storage = [DTTableViewMemoryStorage storageWithDelegate:model];
        model.dataStorage = storage;
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        [model registerCellClass:[ExampleCell class] forModelClass:[Example class]];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [storage addTableItems:@[acc1,acc2] toSection:0];
        [storage addTableItems:@[acc3,acc4] toSection:1];
        [storage addTableItems:@[acc5,acc6] toSection:2];
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should have correct search results for L symbol", ^{
        [model filterTableItemsForSearchString:@"L"];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(1));
        
        [model verifyTableItem:acc1 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
        
        expect([model tableView:model.tableView numberOfRowsInSection:1]).to(equal(1));
        
        [model verifyTableItem:acc6 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
    });
    
    it(@"should have correct search results for y symbol", ^{
        [model filterTableItemsForSearchString:@"y"];
        
        expect([model numberOfSectionsInTableView:model.tableView]).to(equal(2));
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(1));
        
        [model verifyTableItem:acc2 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
        
        expect([model tableView:model.tableView numberOfRowsInSection:1]).to(equal(1));
        
        [model verifyTableItem:acc3 atIndexPath:[NSIndexPath indexPathForRow:0
                                                                   inSection:1]];
    });
    
    it(@"should have all items for a query", ^{
        [model filterTableItemsForSearchString:@"a"];
        
        expect([model tableView:model.tableView numberOfRowsInSection:0]).to(equal(2));
        
        expect([model tableView:model.tableView numberOfRowsInSection:1]).to(equal(2));
        
        expect([model tableView:model.tableView numberOfRowsInSection:2]).to(equal(2));
    });
    
    it(@"should have nothing for ost", ^{
        [model filterTableItemsForSearchString:@"ost"];
        
        expect([model numberOfSectionsInTableView:model.tableView]).to(equal(0));
    });
    
});

describe(@"section headers/footers titles", ^{
   
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        testModel = [Example exampleWithText:@"Dehli" andDetails:@"India"];
        
        model = [DTTableViewController new];
        storage = [DTTableViewMemoryStorage storageWithDelegate:model];
        model.dataStorage = storage;
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.sectionHeaderStyle = DTTableViewSectionStyleTitle;
        model.sectionFooterStyle = DTTableViewSectionStyleTitle;
        [model registerCellClass:[ExampleCell class] forModelClass:[Example class]];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [storage setSectionHeaderModels:@[@"header1",
                                          @"header2",
                                          @"header3"]];

        [storage setSectionFooterModels:@[@"footer1",
                                          @"footer2",
                                          @"footer3"]];
        
        [storage addTableItems:@[acc1,acc2] toSection:0];
        [storage addTableItems:@[acc3,acc4] toSection:1];
        [storage addTableItems:@[acc5,acc6] toSection:2];
        
        [model filterTableItemsForSearchString:@"s"];
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should have correct header titles", ^{
        expect([model tableView:model.tableView titleForHeaderInSection:0]).to(equal(@"header2"));
        expect([model tableView:model.tableView titleForHeaderInSection:1]).to(equal(@"header3"));
    });
    
    it(@"should have correct footer titles", ^{
        expect([model tableView:model.tableView titleForFooterInSection:0]).to(equal(@"footer2"));
        expect([model tableView:model.tableView titleForFooterInSection:1]).to(equal(@"footer3"));
    });

});

describe(@"section headers/footers models", ^{
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        testModel = [Example exampleWithText:@"Dehli" andDetails:@"India"];
        
        model = [DTTableViewController new];
        storage = [DTTableViewMemoryStorage storageWithDelegate:model];
        model.sectionHeaderStyle = DTTableViewSectionStyleView;
        model.sectionFooterStyle = DTTableViewSectionStyleView;
        model.dataStorage = storage;
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        [model registerCellClass:[ExampleCell class] forModelClass:[Example class]];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        if ([UITableViewHeaderFooterView class]) { // iOS 6 and higher test
            [model registerHeaderClass:[MockTableHeaderFooterView class]
                         forModelClass:[Example class]];
            [model registerFooterClass:[MockTableHeaderFooterView class]
                         forModelClass:[Example class]];
            
            [storage setSectionHeaderModels:@[acc1,acc3,acc5]];
            [storage setSectionFooterModels:@[acc2,acc4,acc6]];
            [storage addTableItems:@[acc1,acc2] toSection:0];
            [storage addTableItems:@[acc3,acc4] toSection:1];
            [storage addTableItems:@[acc5,acc6] toSection:2];
            
            [model filterTableItemsForSearchString:@"s"];
        }
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should have correct header models", ^{
        if ([UITableViewHeaderFooterView class]) {
            UIView * view = [model tableView:model.tableView viewForHeaderInSection:0];
            expect([(id <DTTableViewModelTransfer>)view model]).to(equal(acc3));
            
            view = [model tableView:model.tableView viewForHeaderInSection:1];
            expect([(id <DTTableViewModelTransfer>)view model]).to(equal(acc5));
        }
    });
    
    it(@"should have correct footer models", ^{
        if ([UITableViewHeaderFooterView class]) {
            UIView * view = [model tableView:model.tableView viewForFooterInSection:0];
            expect([(id <DTTableViewModelTransfer>)view model]).to(equal(acc4));
            
            view = [model tableView:model.tableView viewForFooterInSection:1];
            expect([(id <DTTableViewModelTransfer>)view model]).to(equal(acc6));
        }
    });
    
});

SPEC_END
