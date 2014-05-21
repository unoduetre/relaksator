public abstract class Widget
{
  protected PApplet pApplet;
  
  public Widget(PApplet pApplet)
  {
    this.pApplet = pApplet;
  }
  
  public abstract void draw();
}
