import com.donaciones.dao.CampaniaDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.model.Campania;
try {
    var dao = new CampaniaDAO();
    ResultadoPaginado<Campania> r = dao.buscarYPaginar("", "Todas", 1, 1, 4);
    System.out.println("ok total=" + r.getTotalRegistros() + " datos=" + (r.getDatos()==null?0:r.getDatos().size()));
    if (r.getDatos()!=null && !r.getDatos().isEmpty()) {
      var c = r.getDatos().get(0);
      System.out.println(c.getIdCampania()+" "+c.getNombre()+" "+c.getEstado()+" "+c.getMontoObjetivo());
    }
} catch (Throwable t) {
    t.printStackTrace();
}
/exit