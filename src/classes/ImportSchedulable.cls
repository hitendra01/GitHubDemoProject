global class ImportSchedulable implements Schedulable {

    global static String start() {
        return System.schedule('RCM1 Importer', '0 0 23 * * ?', new ImportSchedulable());
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new Rcm1Importer(), 5);
    }

}