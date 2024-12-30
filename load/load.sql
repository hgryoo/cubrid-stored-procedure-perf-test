CREATE OR REPLACE FUNCTION fn_string(s string) RETURN STRING
as language java name 'SpPrepareTest.testString(java.lang.String) return java.lang.String';

CREATE OR REPLACE FUNCTION fn_int(i int) RETURN INT
as language java name 'SpPrepareTest.testInt(java.lang.Integer) return java.lang.Integer';

CREATE OR REPLACE FUNCTION fn_test_query(i int) RETURN STRING
as language java name 'SpPrepareTest.testWithSQL(int) return java.lang.String';