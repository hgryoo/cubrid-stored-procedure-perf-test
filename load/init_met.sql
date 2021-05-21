DROP CLASS dummy;
CREATE CLASS dummy (a int);

ALTER CLASS dummy add method class m_t0(int) int function m_t0 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t1(int,int) int function m_t1 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t2(int) int function m_t2 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t3(int) string function m_t3 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t4(int) string function m_t4 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t5(string) string function m_t5 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t6(int) string function m_t6 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_broker_stat() string function m_broker_stat file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';
ALTER CLASS dummy add method class m_t7() set function m_t7 file '$CUBRID/method/method.so', '$CUBRID/lib/libcubridesql.so';