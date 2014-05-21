import saito.objloader.OBJModel;

public class Head extends Part
{

  
  public Head(PApplet pApplet)
  {
    super(pApplet,new OBJModel(pApplet, "head.obj","relative",TRIANGLES));
    model.translate(new PVector(0,-5.9,0)); //środek na wysokości nosa :-)
  }
  
  public void draw()
  {
    model.draw();
  }
}
