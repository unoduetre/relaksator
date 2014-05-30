import java.util.List;
import java.util.ArrayList;

public abstract class Part extends Widget
{
  private Collada collada = null;
  public Part(PApplet pApplet, String fileName)
  {
    super(pApplet);
    collada = new Collada(pApplet.loadXML(fileName));
  }
 
  public void draw()
  {
  }
  
  
}

public abstract class ColladaPart
{
  public ColladaPart()
  {
  }

}

public class Collada extends ColladaPart
{
  protected List<ColladaLibraryGeometries> libraryGeometriesList = new ArrayList<ColladaLibraryGeometries>();
  
  public Collada(XML collada)
  {
    super();
    for(XML libraryGeometries : collada.getChildren("library_geometries"))
    {
      libraryGeometriesList.add(new ColladaLibraryGeometries(libraryGeometries));
    }
  }
}

public class ColladaLibraryGeometries extends ColladaPart
{
  protected List<ColladaGeometry> geometryList = new ArrayList<ColladaGeometry>();
  
  public ColladaLibraryGeometries(XML libraryGeometries)
  {
    super();
    for(XML geometry : libraryGeometries.getChildren("geometry"))
    {
      geometryList.add(new ColladaGeometry(geometry));
    }    
  }
}

public class ColladaGeometry extends ColladaPart
{
  protected ColladaMesh mesh = null;
  
  public ColladaGeometry(XML geometry)
  {
    super();
    XML child = null;
    if((child = geometry.getChild("mesh")) != null)
    {
      mesh = new ColladaMesh(child);
    }
  }
}

public class ColladaMesh extends ColladaPart
{
  protected List<ColladaSource> sourceList = new ArrayList<ColladaSource>();
  
  public ColladaMesh(XML mesh)
  {
    super();
    for(XML source : mesh.getChildren("source"))
    {
      sourceList.add(new ColladaSource(source));
    }    
  }
}

public class ColladaSource extends ColladaPart
{
  public ColladaSource(XML source)
  {
    super();
    
  }
}
