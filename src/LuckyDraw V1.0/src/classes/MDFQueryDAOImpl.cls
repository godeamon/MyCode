public with sharing class MDFQueryDAOImpl implements MDFQueryDAO {
	
	public List<MetricsDataFile> findMDFs(String sendingInstanceId, Date lookbackStartDate) {
		return  [SELECT NamespacePrefix, MetricsDataFileLength, MetricsDataFile FROM MetricsDataFile 
    														WHERE SendingInstance = :sendingInstanceId 
    														AND MetricsStartDate >= :lookbackStartDate];
	}
	
    public List<MetricsDataFile> findMDFs(String metricsType, String namespacePrefix, Date lookbackStartDate) {
        List<MetricsDataFile> mdfs =  [SELECT Id, SendingInstance, NamespacePrefix, MetricsType, MetricsStartDate, MetricsEndDate, MetricsRunDate, MetricsDataFileLength, MetricsDataFile
                        FROM MetricsDataFile WHERE MetricsType = :metricsType AND NamespacePrefix = :namespacePrefix
                        AND MetricsStartDate >= :lookbackStartDate ORDER BY MetricsStartDate DESC];
        
         
        // With the addition of the MetricsRunDate field there is possibility a date can have multiple results. In that case take the result with the latest run date        
        Map<String, MetricsDatafile> resultsKeys = new Map<String, MetricsDataFile>();       
        for(MetricsDataFile m: mdfs){    
            String key = m.SendingInstance + '|' + m.NamespacePrefix.toUpperCase() + '|' + m.MetricsType +  '|' + m.MetricsStartDate;
            if (!resultsKeys.containsKey(key)){
            	
               resultsKeys.put(key, m);
            } 
            else {
              // we have multiple results/entries for this key
              DateTime runDateInMap = resultsKeys.get(key).MetricsRunDate;
              DateTime currentRunDate = m.MetricsRunDate;
              // If this rundate is later than what's in the map, replace it
              if (currentRunDate > runDateInMap){
                resultsKeys.put(key, m);
              }
            }
        }         
          return resultsKeys.values();
    }
	
	public Set<String> findNamespaces() {
		Set<String> namespaces = new Set<String>();

		List<AggregateResult> results =  [SELECT NamespacePrefix FROM MetricsDataFile GROUP BY NamespacePrefix limit 25];
		for(AggregateResult r : results){
			namespaces.add(String.valueOf(r.get('NamespacePrefix')).toUpperCase());
		}   
		
		return namespaces;     	
	}
}