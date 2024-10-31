CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "DPP_TOOLKIT" AS 
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import oracle.jdbc.OracleDriver;
import oracle.jdbc.pool.OracleDataSource;
import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import oracle.sql.ArrayDescriptor;
import oracle.sql.ARRAY;

public class dpp_toolkit {

  private static String directoryScan = "SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM "
      + "ALL_DIRECTORIES A WHERE DIRECTORY_NAME = ?";

  private static void closeAll(Connection c, ResultSet rs) {
    if (rs != null) {
      try {
        rs.close();
      } catch (SQLException sqle) {

      }
    }
    if (c != null) {
      try {
        c.close();
      } catch (SQLException sqle) {

      }
    }
  }

  private static Connection open() {
    Connection c = null;
    OracleDataSource ods = null;
    try {

      OracleDriver ora = new OracleDriver();
      c = ora.defaultConnection();
      System.err.println("connected to default");
    } catch (SQLException sqle) {
      c = null;
      System.err.println("connected to default FAILED!");
    }
    if (c != null) {
      return c;
    }
    throw new NullPointerException("default conn failed");
  }

  private static String[] scanFiles(File pathName) {
    File[] temp_list;
    String[] rc;
    if (pathName == null) {
      throw new IllegalArgumentException("pathName is null");
    }
    if (!pathName.isDirectory()) {
      throw new IllegalArgumentException("Is not a directory:" + pathName);
    }

    // temp_list =pathName.listFiles();//.listFiles(new ExpFileFilter());
    // //convert them to string list
    // rc = new String[temp_list.length];
    // for (int i=0;i<temp_list.length;i++){
    // rc[i] = temp_list[i].getName();
    // }
    rc = pathName.list();
    return rc;
    // return new
    // String[]{"dir1","dir2",(pathName.isDirectory()?"direct":"file")};
  }

  public static ARRAY scanFiles(String pDirectoryObject) {
    String l_path = null;
    String[] paths = null;
    ArrayDescriptor arrayDescriptor = null;
    Connection c = open();
    ARRAY listed = null;
    int marker = 0;

    if (c == null) {
      throw new NullPointerException("No connection to DB possible!");
    }
    ResultSet rs = null;
    try {
      PreparedStatement p = c.prepareStatement(directoryScan);
      p.setString(1, pDirectoryObject);
      rs = p.executeQuery();
      if (rs.next()) {
        marker = 1;
        l_path = rs.getString("DIRECTORY_PATH");
        marker = 2;
        paths = scanFiles(new File(l_path));
        marker = 3;
        arrayDescriptor = new ArrayDescriptor("T_FILE_LIST", c);
        marker = 4;
        listed = new ARRAY(arrayDescriptor, c, ((Object[]) paths));
      } else {
        throw new NullPointerException("Directory object "
            + pDirectoryObject + " not found!");
      }
    } catch (SQLException sqle) {
      System.err.println(sqle.getMessage());
      throw new NullPointerException("No connection to DB possible!:"
          + sqle.getMessage());
    } finally {
      closeAll(c, rs);
    }
    if (listed == null) {
      throw new NullPointerException("ARRAY return object is NULL!");
    }
    return listed;
  }

  public static void main(String[] args) {
    scanFiles("DATAPUMP1");
  }
}
/