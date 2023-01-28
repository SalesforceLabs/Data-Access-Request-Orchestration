public with sharing class GetDataOwnersList {
    @InvocableMethod(label='Get Field Definition Info' description='Returns Sensitive Fields OR Field Owners' )
    public static List<Results> getFieldInfo(List<Requests> requestList) {
      String inputRequest = requestList[0].inputCondition;
      if (inputRequest.contains('.')){
        requestList[0].isFieldList = false;
      } else {
        requestList[0].isFieldList = true;
      }
      Boolean getFieldNames = requestList[0].isFieldList;
      List<String> outputList = new List<String>();
      String ownerId = '';
      if (getFieldNames){
        List<FieldDefinition> fieldList = [SELECT Id, DeveloperName, businessowner.name, ComplianceGroup, SecurityClassification 
          FROM FieldDefinition WHERE EntityDefinition.QualifiedAPIName = :inputRequest AND SecurityClassification != null ];
        outputList.add(inputRequest +' Sensitive Field List with Security Level, Compliance Group (if any), and Business Owner (if any): ' + '\n');
        for (FieldDefinition fd : fieldList) {
          String output = '\n '+ fd.DeveloperName +' - '+ fd.SecurityClassification +', '+ fd.ComplianceGroup +', '+ fd.BusinessOwner.name +'.' + '\n';
          outputList.add(output.replace('null', 'none'));
        }
      } else {
        List<String>inputRequestList = inputRequest.split('\\.',0);
        if(inputRequestList.size()!=2){
          return new List<Results>();
        }
        List<String> entityList = new List<String>();
        List<String> fieldList = new List<String>();
        fieldList.add(inputRequestList[1]);
        entityList.add(inputRequestList[0]);
        String thisFieldOwnerId = [SELECT BusinessOwnerId FROM FieldDefinition WHERE DeveloperName IN :fieldList AND entitydefinitionid IN :entityList LIMIT 1]?.BusinessOwnerId;
        outputList.clear();
        outputList.add(thisFieldOwnerId);
        if(thisFieldOwnerId.startsWith('005')){
          String ownerUserName = [SELECT Username FROM User WHERE id = :thisFieldOwnerId]?.Username;
          outputList.add(ownerUserName);
        }
        if(thisFieldOwnerId.startsWith('00G')){
          String ownerGroupDeveloperName = [SELECT DeveloperName FROM Group WHERE id = :thisFieldOwnerId]?.DeveloperName;
          outputList.add(ownerGroupDeveloperName);
        }
      }
      List<Results> resultList = new List<Results>();
      Results thisResult = new Results();
      thisResult.outputList = outputList;
      resultList.add(thisResult);
      return resultList;
    }
  
  public class Requests {
    @InvocableVariable(label='Input API Name' description='API Name for Object or Field' required=true)
    public String inputCondition;
    @InvocableVariable(label='Input Type' description='Select True if API Name is for an Object' required=true)
    public Boolean isFieldList;
    }
  
  public class Results {
    @InvocableVariable(label='Data for Output' description='yourDescription' required=true)
    public List<String> outputList = new List<String>();
    }
}