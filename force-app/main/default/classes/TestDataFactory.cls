/**
 * TestDataFactory contain methods that can be called by test methods to perform useful tasks
 */
@isTest
public class TestDataFactory {
    
    public static List<Lead> createLeadsByTitle(List<String> titles, Boolean doInsert) {
        List<Lead> leadsToInsert = new List<Lead>();
        for (String title : titles) {
            leadsToInsert.add(
                new Lead(LastName = 'Test Lead ' + title, 
                        Company = 'Test Company', 
                        Title = title));
        }
        if (doInsert) {
            Database.insert(leadsToInsert);
        }

        return leadsToInsert;
    }
}