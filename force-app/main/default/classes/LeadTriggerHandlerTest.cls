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
}