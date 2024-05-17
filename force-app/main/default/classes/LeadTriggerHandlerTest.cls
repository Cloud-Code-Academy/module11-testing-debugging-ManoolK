/**
 * This class contains unit tests for validating the behavior of 
 * Apex class LeadTriggerHandler
 * and trigger LeadTrigger.
 *
 * Implemented by Oxana Suvorova
 */
@isTest
private class LeadTriggerHandlerTest {

    /*
    * LeadTriggerHandler.handleTitleNormalization insert test
    */
    @isTest
    static void testHandleTitleNormalization_insert() {
        // Prepare the test data
        List<String> titles = new List<String>{
            'vp', 'v.p.', 'vice president', 'VPOTUS', 'V.P.', 'vice person', // 5 'Vice President'
            'mgr', 'manage', 'head of department', '', 'Manager', // 4 'Manager'
            'exec', 'chief', 'head', 'Chief Executive', null, // 4 'Executive'
            'assist', 'deputy', 'jr', 'DEPUTY', 'junior'}; // 4 'Assistant'

        List<Lead> leadsToInsert = TestDataFactory.createLeadsByTitle(titles, false);

        // Perform the test
        Test.startTest();
        Database.insert(leadsToInsert);
        Test.stopTest();

        // Retrieve the count of Leads grouped by Title
        List<AggregateResult> groupedLeads = [
            SELECT 
                Title, 
                COUNT(Name) aggCount
            FROM Lead
            GROUP BY Title
        ];

        Map<String, Integer> countsByTitle = new Map<String, Integer>();
        Integer totalRecords = 0;
        for (AggregateResult ar : groupedLeads) {
            totalRecords += (Integer) ar.get('aggCount');
            countsByTitle.put((String) ar.get('Title'), (Integer) ar.get('aggCount'));
        }

        // Assert that the Title have been correctly changed
        Assert.isTrue(countsByTitle.get('Vice President') == 5, 'Expected 5 Leads with Title \'Vice President\'');
        Assert.isTrue(countsByTitle.get('Manager') == 4, 'Expected 4 Leads with Title \'Manager\'');
        Assert.isTrue(countsByTitle.get('Executive') == 4, 'Expected 4 Leads with Title \'Executive\'');
        Assert.isTrue(countsByTitle.get('Assistant') == 4, 'Expected 4 Leads with Title \'Assistant\'');
        Assert.areEqual(21, totalRecords, 'Expected 21 Lead records');
    }

    /*
    * LeadTriggerHandler.handleTitleNormalization update test
    */
    @isTest
    static void testHandleTitleNormalization_update() {
        // Prepare the test data
        List<String> titles = new List<String>{'asist', 'depty', 'junior', null, ''};
        List<Lead> leadsToUpdate = TestDataFactory.createLeadsByTitle(titles, true);

        for (Lead lead : leadsToUpdate) {
            lead.Title = 'jr';
        }
        // Perform the test
        Test.startTest();
        Database.update(leadsToUpdate);
        Test.stopTest();

        // Retrieve updated Leads
        List<Lead> leadsAfterUpdate = [
            SELECT 
                Title
            FROM Lead
            WHERE Id IN :leadsToUpdate
        ];

        // Assert that the Title have been correctly updated
        Assert.isTrue(leadsAfterUpdate.size() == 5, 'Expected 5 Lead records');
        for (Lead lead : leadsAfterUpdate) {
            Assert.areEqual('Assistant', lead.Title, 'Expected Title \'Assistant\'');
        }
    }

    /*
    * LeadTriggerHandler.handleTitleNormalization update test
    */
    @isTest
    static void testHandleAutoLeadScoring() {
        // Prepare the test data
        List<Map<String, Object>> params = new List<Map<String, Object>>();
        params.add(new Map<String, Object>{'Lead_Score__c' => 20, 'LeadSource' => null}); // 0
        params.add(new Map<String, Object>{'LeadSource' => 'Other', 'Email' => 'test@mail.com'}); // 0
        params.add(new Map<String, Object>{'LeadSource' => 'Web', 'Email' => 'test@mail.com'}); // 3
        params.add(new Map<String, Object>{'Phone' => '(908)345-1234', 'Industry' => 'Government'}); // 5
        params.add(new Map<String, Object>{'LeadSource' => 'Web', 'Email' => 'test2@mail.com', 'Phone' => '(908)345-2345'}); // 8
        params.add(new Map<String, Object>{'Lead_Score__c' => 10, 'Email' => 'test3@mail.com', 'Industry' => 'Technology'}); // 10
        params.add(new Map<String, Object>{'LeadSource' => 'Web', 'Email' => 'test4@mail.com', 'Industry' => 'Technology'}); // 13
        params.add(new Map<String, Object>{'LeadSource' => 'Web', 'Phone' => '(908)346-1234', 'Industry' => 'Technology'}); // 15
        params.add(new Map<String, Object>{'LeadSource' => 'Web', 'Email' => 'test5@mail.com', 
                                           'Phone' => '(908)346-1234', 'Industry' => 'Technology'}); // 18

        List<Lead> leadsToScore = TestDataFactory.createLeadsByParams(params, false);
        
        // Perform the test
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leadsToScore);
        Test.stopTest();

        // Assert that the Score calculates correctly
        List<Integer> scoreVariants = new List<Integer>{0, 0, 3, 5, 8, 10, 13, 15, 18};
        for (Integer i = 0; i < leadsToScore.size(); i++) {
            Assert.isTrue(leadsToScore[i].Lead_Score__c <= 18, 'Lead score shouldn\'t be more than 18');
            Assert.areEqual(scoreVariants[i], leadsToScore[i].Lead_Score__c, 'Score has not correctly calculated');
        }
        
    }
}