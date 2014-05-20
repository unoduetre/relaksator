import saito.objloader.OBJModel;

public class Head
{
  private PApplet pApplet = null;
  private Integer width = null;
  private Integer height = null;
  private OBJModel model = null;
  
  public Head(PApplet pApplet, int width, int height)
  {
    this.pApplet = pApplet;
    this.width = width;
    this.height = height;
    model = new OBJModel(pApplet, "head.obj","relative",TRIANGLES);
    model.translate(new PVector(0,-5.9,0)); //środek na wysokości nosa :-)
  }
  
  public void draw()
  {
    model.draw();
  }
}
