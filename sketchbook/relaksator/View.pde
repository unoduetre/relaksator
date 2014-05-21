public abstract class View extends Widget
{
  public View(PApplet pApplet)
  {
    super(pApplet);
  }

  public abstract void show();
  
  public abstract void hide();
}

