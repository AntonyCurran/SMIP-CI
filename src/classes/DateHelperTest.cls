@isTest
public class DateHelperTest {
    static DateHelper dateHelper = new DateHelper();
    
    testMethod static void testNextMonth() {
        Date nextMonth = dateHelper.nextMonth();
        Date today = System.today();
        Integer year = today.month() < 12 ? today.year() : today.year() + 1;
        Integer month = today.month() < 12 ? today.month() + 1 :  1;
        System.assertEquals(year, nextMonth.year());
        System.assertEquals(month, nextMonth.month());
        System.assertEquals(1, nextMonth.day());
    }
    
    testMethod static void testMonthNameJanuary() {
        Date january = Date.newInstance(2014,1,1);
        String expected = dateHelper.nameOfMonth(january);
        System.assertEquals(expected, 'January');
    }

    testMethod static void testMonthNameDecember() {
        Date december = Date.newInstance(2014,12,1);
        String expected = dateHelper.nameOfMonth(december);
        System.assertEquals(expected, 'December');
    }
}