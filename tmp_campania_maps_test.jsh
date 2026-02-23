import com.donaciones.dao.CampaniaDAO;
import java.util.*;
try {
    var dao = new CampaniaDAO();
    var r = dao.buscarYPaginar("", "Todas", 1, 1, 4);
    var ids = new ArrayList<Integer>();
    for (var c : r.getDatos()) { ids.add(c.getIdCampania()); }
    System.out.println("ids="+ids);
    var m1 = dao.obtenerMontosRecaudados(ids);
    System.out.println("montos="+m1);
    var m2 = dao.contarDonacionesPorCampania(ids);
    System.out.println("conts="+m2);
} catch (Throwable t) { t.printStackTrace(); }
/exit