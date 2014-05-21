public abstract class Part extends Widget
{
  protected OBJModel model = null;
  
  public Part(PApplet pApplet, OBJModel model)
  {
    super(pApplet);
    this.model = model;
  }
}
