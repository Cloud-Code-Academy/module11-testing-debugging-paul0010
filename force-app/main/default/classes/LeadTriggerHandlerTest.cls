@isTest
public with sharing class LeadTriggerHandlerTest {

    @isTest
    static void testHandleTitleNormalization(){
        List<String> testTitles1 = new List<string>{'vp', 'v.p.', 'vice president'};
        List<String> testTitles2 = new List<string>{'mgr', 'manage', 'head of department'};
        List<String> testTitles3 = new List<string>{'exec', 'chief', 'head'};
        List<String> testTitles4 = new List<string>{'assist', 'deputy', 'jr'};
        List<Lead> testLeads = new List<Lead>();

        for (Integer i = 0; i < 3; i++) {
            Lead testLead1 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Title = 'Test '+ testTitles1[i]);
            Lead testLead2 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Title = 'Test '+ testTitles2[i]);
            Lead testLead3 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Title = 'Test '+ testTitles3[i]);
            Lead testLead4 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Title = 'Test '+ testTitles4[i]);
            testLeads.add(testLead1);
            testLeads.add(testLead2);
            testLeads.add(testLead3);
            testLeads.add(testLead4);
        }

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(testLeads);
        Test.stopTest();

        System.assertEquals('Vice President', testLeads[0].Title, 'The Title should be Vice President.');
        System.assertEquals('Vice President', testLeads[4].Title, 'The Title should be Vice President.');
        System.assertEquals('Vice President', testLeads[8].Title, 'The Title should be Vice President.');
        System.assertEquals('Manager', testLeads[1].Title, 'The Title should be Manager.');
        System.assertEquals('Manager', testLeads[5].Title, 'The Title should be Manager.');
        System.assertEquals('Manager', testLeads[9].Title, 'The Title should be Manager.');
        System.assertEquals('Executive', testLeads[2].Title, 'The Title should be Executive.');
        System.assertEquals('Executive', testLeads[6].Title, 'The Title should be Executive.');
        System.assertEquals('Executive', testLeads[10].Title, 'The Title should be Executive.');
        System.assertEquals('Assistant', testLeads[3].Title, 'The Title should be Assistant.');
        System.assertEquals('Assistant', testLeads[7].Title, 'The Title should be Assistant.');
        System.assertEquals('Assistant', testLeads[11].Title, 'The Title should be Assistant.');
    }

    @isTest
    static void testHandleAutoLeadScoring() {
        List<Lead> testLeads = new List<Lead>();
        Lead testLead1 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', LeadSource = 'Website');
        Lead testLead2 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', LeadSource = 'Website', Email = 'test@test.com');
        Lead testLead3 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Phone = '+12345678910');
        Lead testLead4 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Industry = 'Technology');
        Lead testLead5 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', LeadSource = 'Website', Email = 'test@test.com', Phone = '+12345678910', Industry = 'Technology');
        
        testLeads.add(testLead1);
        testLeads.add(testLead2);
        testLeads.add(testLead3);
        testLeads.add(testLead4);
        testLeads.add(testLead5);

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(testLeads);
        Test.stopTest();

        System.assertEquals(0, testLeads[0].Lead_Score__c, 'The lead score should be 0.');
        System.assertEquals(3, testLeads[1].Lead_Score__c, 'The lead score should be 3.');
        System.assertEquals(5, testLeads[2].Lead_Score__c, 'The lead score should be 5.');
        System.assertEquals(10, testLeads[3].Lead_Score__c, 'The lead score should be 10.');
        System.assertEquals(18, testLeads[4].Lead_Score__c, 'The lead score should be 18.');
    }

    @isTest
    static void testHandleLeadAutoConvert(){
        List<Contact> testContacts = new List<Contact>();
        List<Lead> testLeads = new List<Lead>();
        Account testAccount1 = new Account(Name = 'Test Account');

        insert testAccount1;

        Contact testContact1 = new Contact(LastName = 'Test Contact', Email = 'test@test.com', AccountId = testAccount1.Id);
        Contact testContact2 = new Contact(LastName = 'Test Contact', Email = 'test2@test.com', AccountId = testAccount1.Id);
        Contact testContact3 = new Contact(LastName = 'Test Contact', Email = 'test2@test.com', AccountId = testAccount1.Id);
        Lead testLead1 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Email = 'test@test.com');
        Lead testLead2 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Email = 'test2@test.com');
        Lead testLead3 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Email = 'test3@test.com');

        testContacts.add(testContact1);
        testContacts.add(testContact2);
        testContacts.add(testContact3);
        testLeads.add(testLead1);
        testLeads.add(testLead2);
        testLeads.add(testLead3);

        insert testContacts;

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> convertedLeads = [SELECT Id, IsConverted, Email FROM Lead WHERE Id = :testLeads];
        System.debug('convertedLeads: '+convertedLeads);

        for (Lead testLead : convertedLeads) {
            if (testLead.Email == 'test@test.com') {
                System.assertEquals(true, testLead.IsConverted, 'The lead should be converted.');
            }
            if (testLead.Email == 'test2@test.com') {
                System.assertEquals(false, testLead.IsConverted, 'The lead should not be converted.');
            }
            if (testLead.Email == 'test3@test.com') {
                System.assertEquals(false, testLead.IsConverted, 'The lead should not be converted.');
            }
        }
    }
}