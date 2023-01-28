@IsTest 
public class GetDataOwnersList_Test {
    @IsTest 
    static void getDataOwner() {
        List<GetDataOwnersList.Requests> requestList = new List<GetDataOwnersList.Requests>();
        GetDataOwnersList.Requests request = new GetDataOwnersList.Requests();
        request.inputCondition = 'Case.ContactPhone';
        requestList.add(request);
        List<GetDataOwnersList.Results> resultList = GetDataOwnersList.getFieldInfo(requestList);
        String fieldSecurity = [SELECT SecurityClassification FROM FieldDefinition WHERE EntityDefinitionId IN ('Case') AND DeveloperName IN ('ContactPhone') ]?.SecurityClassification;
        if(fieldSecurity > '0'){ // testable data exists in the org
            System.assert(resultList[0].outputList.size()>0, 'Missing data owner data'); 
            System.assert(resultList[0].outputList[0].startsWith('00'), 'Returned data Id is not in a supported format');
            System.assert(!resultList[0].outputList[1].startsWith('0'), 'Returned data Name is not in a supported format');
        } else {
            System.assert(resultList.size()>0, 'Only run in orgs where testable metadata exists.'); 
        }
    }
    @IsTest 
    static void getSensitiveFields() {
        List<GetDataOwnersList.Requests> requestList = new List<GetDataOwnersList.Requests>();
        GetDataOwnersList.Requests request = new GetDataOwnersList.Requests();
        request.inputCondition = 'Case';
        requestList.add(request);
        List<GetDataOwnersList.Results> resultList = GetDataOwnersList.getFieldInfo(requestList);
        String fieldSecurity = [SELECT SecurityClassification FROM FieldDefinition WHERE EntityDefinitionId IN ('Case') AND DeveloperName IN ('ContactPhone') ]?.SecurityClassification;
        if(fieldSecurity > '0'){ // testable data exists in the org
            System.assert(resultList[0].outputList.size()>0, 'Missing security classification record.'); 
            System.assert(resultList[0].outputList[0].contains('Case'), 'Missing object name in initial result string');
        } else {
            System.assert(resultList.size()>0, 'Only run in orgs where testable metadata exists.'); 
        }
    }
    @IsTest 
    static void returnNoResultsForBadInput() {
        List<GetDataOwnersList.Requests> requestList = new List<GetDataOwnersList.Requests>();
        GetDataOwnersList.Requests request = new GetDataOwnersList.Requests();
        request.inputCondition = 'Case.ContactPhone.NestingError';
        requestList.add(request);
        List<GetDataOwnersList.Results> resultList = GetDataOwnersList.getFieldInfo(requestList);
            System.assert(resultList.size()==0, 'Bad input should return no results');
    }
}