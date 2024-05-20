/**
 * TestDataFactory contain methods that can be called by test methods to perform useful tasks
 */
@isTest
public class TestDataFactory {
    
    /**
     * Creates test Account
     * @param name The name value for the Account
     * @param doInsert Set true to insert new created records to the database
     */
    public static Account getAccount(String name, Boolean doInsert) {
        Account acc = new Account(Name = name);
        if (doInsert) {
            Database.insert(acc);
        }
        return acc;
    }

    /**
     * Generates test Account and its Contacts with emails.
     * @param numContacts The number of contacts to generate
     * @param fraction The number by which create unique emails
     * Ex: If generate 50 contacts with fraction 7 we will get 7 Contacts with unique emails
     * For fraction 5 we need 5x5+1 Contact to generate
     */
    public static void generateAccountWithContacts(Integer numContacts, Integer fraction) {
        Account acc = getAccount('Default Account ltd', true);
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numContacts; i++) {
            if (Math.mod(i, fraction) == 0) {
                contacts.add(new Contact(FirstName = 'Test', 
                                            LastName = 'contact' + i, 
                                            accountId = acc.Id,
                                            Email = 'test' + i + '@mail.com'));
            } else {
                contacts.add(new Contact(FirstName = 'Test', 
                                            LastName = 'contact' + i, 
                                            accountId = acc.Id,
                                            Email = 'test' + Math.round(i / fraction) + '@mail.com'));
            }
        }
        Database.insert(contacts);
    }

    /**
     * Creates new Leads.
     * @param titles The list of Titles 
     * @param doInsert Set true to insert new created records to the database
     * We will get so many Leads as number of Titles in the list
     */
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

    /**
     * Creates new Leads.
     * We will get so many Leads as number of param sets passed to the method
     * @param params The list of maps that contains pairs of fieldName/value
     * @param doInsert Set true to insert new created records to the database
     */
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

    /**
     * Creates new Leads.
     * get Leads with set of fields 
     * Email field generates separately if it was set in params. 
     * @param numLeads The number of Leads to generate
     * @param params The map that contains pairs of fieldName/value
     * @param doInsert Set true to insert new created records to the database
     */
    public static List<Lead> createLeadsWithParams(Integer numLeads, Map<String, Object> params, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < numLeads; i++) {
            Lead lead = new Lead();
            lead.LastName = 'Test Lead ' + i;
            lead.Company = 'Test Compaany';
            for (String key : params.keySet()) {
                if (key == 'Email') {
                    lead.Email = 'test' + i + '@mail.com';
                } else {
                    lead.put(key, params.get(key));
                }
            }
            leads.add(lead);
        }
        if (doInsert) {
            Database.insert(leads);
        }
        return leads;
    }
}