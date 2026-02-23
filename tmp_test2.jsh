import com.donaciones.dao.*;
import java.sql.Date;
import java.time.LocalDate;
import java.math.BigDecimal;
DonacionDAO dao = new DonacionDAO();
try {
  int id = dao.crear(6, 2, "Monetaria", "Pendiente", Date.valueOf(LocalDate.now()), new BigDecimal("321.00"), "Prueba DAO post-fix");
  System.out.println("ID=" + id);
} catch (Exception e) {
  e.printStackTrace();
}
/exit
