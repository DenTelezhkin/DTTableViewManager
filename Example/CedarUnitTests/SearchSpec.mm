#import "DTTableViewManager.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SearchSpec)

__block DTTableViewManager *model;
__block Example * acc1;
__block Example * acc2;
__block Example * acc3;
__block Example * acc4;
__block Example * acc5;
__block Example * acc6;

describe(@"search in first section", ^{
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        model = [DTTableViewManager new];
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [model addTableItems:@[acc1,acc2,acc3,acc4,acc5,acc6]];
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should find 2 items with double s", ^{
        [model filterTableItemsForSearchString:@"ss"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(2));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Lissabon"));
    });
    
    it(@"should find none items for iva", ^{
        [model filterTableItemsForSearchString:@"iva"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(0));
    });
    
    it(@"should find 1 item for cow", ^{
        [model filterTableItemsForSearchString:@"cow"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Moscow"));
    });
    
    it(@"should find 1 item for white space", ^{
        [model filterTableItemsForSearchString:@" "];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Washington D.C."));
    });
    
    it(@"should find 1 item for .", ^{
        [model filterTableItemsForSearchString:@"."];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Washington D.C."));
    });
    
    it(@"should find all items for empty search string", ^{
        [model filterTableItemsForSearchString:@"."];
        
        [model filterTableItemsForSearchString:@""];
        
        expect([[model tableItemsInSection:0] count]).to(equal(6));
    });
    
    it(@"should find rai items", ^{
        [model filterTableItemsForSearchString:@"rai"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
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
        
        model = [DTTableViewManager new];
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [model addTableItems:@[acc1,acc2] toSection:0];
        [model addTableItems:@[acc3,acc4] toSection:1];
        [model addTableItems:@[acc5,acc6] toSection:2];
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should have correct search results for L symbol", ^{
        [model filterTableItemsForSearchString:@"L"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[model tableItemsInSection:0] lastObject]).to(equal(acc1));
        
        expect([[model tableItemsInSection:1] count]).to(equal(1));
        
        expect([[model tableItemsInSection:1] lastObject]).to(equal(acc6));
    });
    
    it(@"should have correct search results for y symbol", ^{
        [model filterTableItemsForSearchString:@"y"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[model tableItemsInSection:0] lastObject]).to(equal(acc2));
        
        expect([[model tableItemsInSection:1] count]).to(equal(1));
        
        expect([[model tableItemsInSection:1] lastObject]).to(equal(acc3));
        
        expect([[model tableItemsInSection:2] count]).to(equal(0));
    });
    
    it(@"should have all items for a query", ^{
        [model filterTableItemsForSearchString:@"a"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(2));
        
        expect([[model tableItemsInSection:1] count]).to(equal(2));
        
        expect([[model tableItemsInSection:2] count]).to(equal(2));
    });
    
    it(@"should have nothing for ost", ^{
        [model filterTableItemsForSearchString:@"ost"];
        
        expect([[model tableItemsInSection:0] count]).to(equal(0));
        
        expect([[model tableItemsInSection:1] count]).to(equal(0));
        
        expect([[model tableItemsInSection:2] count]).to(equal(0));
    });
    
    context(@"original getters",^{
        
        beforeEach(^{
            [model filterTableItemsForSearchString:@"abcde"];
            
            expect([model numberOfSections]).to(equal(0));
        });
        
        it(@"should correctly work for number of table items in original section", ^{
            expect([model numberOfTableItemsInOriginalSection:0]).to(equal(2));
            
            expect([model numberOfTableItemsInOriginalSection:1]).to(equal(2));
            
            expect([model numberOfTableItemsInOriginalSection:2]).to(equal(2));
        });
        
        it(@"should correctly work for number of original sections", ^{
            expect([model numberOfOriginalSections]).to(equal(3));
        });
        
        it(@"should correcty get tableItem at original index path", ^{
            expect([model tableItemAtOriginalIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to(equal(acc2));
            
            expect([model tableItemAtOriginalIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).to(equal(acc4));
            
            expect([model tableItemAtOriginalIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]).to(equal(acc6));
        });
        
        it(@"should correctly get table items in original section", ^{
            expect([[model tableItemsInOriginalSection:1] count]).to(equal(2));
            
            expect([[model tableItemsInOriginalSection:0] count]).to(equal(2));
            
            expect([[model tableItemsInOriginalSection:2] count]).to(equal(2));
            
            expect([[model tableItemsInOriginalSection:2] lastObject]).to(equal(acc6));
        });
        
        it(@"should correctly work for index path of original table item", ^{
            expect([model indexPathOfTableItem:acc2]).to(BeNil());
            
            expect([model originalIndexPathOfTableItem:acc2]).to(equal([NSIndexPath indexPathForRow:1 inSection:0]));
            
            expect([model originalIndexPathOfTableItem:acc3]).to(equal([NSIndexPath indexPathForRow:0 inSection:1]));
        });
        
        it(@"should correctly work with index paths of original table items", ^{
            NSArray * items =@[acc1,acc3];
            expect([model indexPathArrayForTableItems:items]).to(equal(@[]));
                    
            expect([model originalIndexPathArrayOfTableItems:items]).to_not(BeNil());
                    
            expect([[model originalIndexPathArrayOfTableItems:items] lastObject]).to(equal([NSIndexPath indexPathForRow:0 inSection:1]));
        });
        
        
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
        
        model = [DTTableViewManager new];
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [model addTableItems:@[acc1] toSection:0];
        [model addTableItems:@[acc3] toSection:1];
        [model addTableItems:@[acc5] toSection:2];
        
        [model filterTableItemsForSearchString:@"d"];
    });
    
    afterEach(^{
        [model release];
        
        [UIView setAnimationsEnabled:YES];
    });
    
    it(@"should add table items to both tables", ^{
        Example * testModel = [Example exampleWithText:@"Dehli" andDetails:@"India"];
        [model addTableItem:testModel toSection:0];
        [model addTableItem:testModel toSection:1];
        
        NSArray * originalTableItems = [model tableItemsInOriginalSection:0];
        NSArray * tableItems = [model tableItemsInSection:0];
        
        expect([originalTableItems count]).to(equal(2));
        expect([tableItems count]).to(equal(2));
        
        expect([originalTableItems lastObject]).to(equal(testModel));
        expect([tableItems lastObject]).to(equal(testModel));
       
        originalTableItems = [model tableItemsInOriginalSection:1];
        tableItems = [model tableItemsInSection:1];
        
        expect([originalTableItems count]).to(equal(1));
        expect([tableItems count]).to(equal(1));
        
        expect([originalTableItems lastObject]).to(equal(testModel));
        expect([tableItems lastObject]).to(equal(testModel));
    });
    
    it(@"should add table items only to original table if filter unmatched", ^{
    
        [model addTableItem:acc2 toSection:0];
        [model addTableItem:acc6 toSection:2];
        
        NSArray * originalTableItems = [model tableItemsInOriginalSection:0];
        NSArray * tableItems = [model tableItemsInSection:0];
        
        expect([originalTableItems count]).to(equal(2));
        expect([tableItems count]).to(equal(1));
        
        expect([tableItems lastObject]).to(equal(acc1));
        expect([originalTableItems lastObject]).to(equal(acc2));
        
        originalTableItems = [model tableItemsInOriginalSection:2];
        tableItems = [model tableItemsInSection:2];
        
        expect([originalTableItems count]).to(equal(2));
        expect([tableItems count]).to(equal(0));
        
        expect([originalTableItems lastObject]).to(equal(acc6));
    });

});

SPEC_END
