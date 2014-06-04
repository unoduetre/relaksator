public static abstract class Widget
{
  protected PApplet pApplet;
  
  public Widget(PApplet pApplet)
  {
    this.pApplet = pApplet;
  }
  
  // Poniższe bo Processing jest debilny
  public int kolor(float v1, float v2, float v3) throws Exception
  {
    return (Integer)Helper.perform(pApplet, "color", new Class<?>[] {Float.TYPE, Float.TYPE, Float.TYPE}, new Float[]{v1, v2, v3});
  }
  
  public abstract void draw();
}
