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

    public static List<Lead> createLeadsByParams(List<Map<String, Object>> params, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < params.size(); i++) {
            Lead newLead = new Lead();
            newLead.LastName = 'Test Lead ' + i;
            newLead.Company = 'Test Company';
            Map<String, Object> locParams = params[i];
            for (String key : locParams.keySet()) {
                newLead.put(key, locParams.get(key));
            }
            leads.add(newLead);
        }
        if (doInsert) {
            Database.insert(leads);
        }

        return leads;
    }
}