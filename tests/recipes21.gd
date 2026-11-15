extends SceneTree
var app
var failures=[]
func _initialize():call_deferred("run")
func check(value:bool,message:String):
 print(message,": ",value)
 if not value:failures.append(message)
func shot(name:String):
 await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa21_"+name+".png")
func tap(at:Vector2):
 var e=InputEventScreenTouch.new();e.index=0;e.position=at;e.pressed=true;Input.parse_input_event(e)
 await process_frame
 e=InputEventScreenTouch.new();e.index=0;e.position=at;e.pressed=false;Input.parse_input_event(e)
 await process_frame;await process_frame
func find_button(text:String):
 for node in app.sheet.get_children():
  if node is Button and text in node.text:return node
 return null
func run():
 app=load("res://main.tscn").instantiate();root.add_child(app)
 await process_frame;await process_frame
 var book:Dictionary=app.recipe_book
 check(book.recipes.size()==197,"197 complete recipes")
 check(book.countries.size()+book.unavailable.size()==app.countries.size(),"Every territory addressed")
 var valid=true
 for code in book.countries:
  var ids=book.countries[code].dishes
  if ids.size()<1 or ids.size()>6:valid=false
  for id in ids:
   var r=book.recipes[id]
   if r.ingredients.size()<2 or r.steps.size()<3 or not r.get("source",{}).get("url","").begins_with("https://"):valid=false
 check(valid,"Capped selections, ingredients, steps and sources")
 check(app.content_sync.valid_recipes(book,app.countries),"Update validator accepts recipe catalogue")
 var broken=book.duplicate(true);broken.countries.FRA.dishes.append("does-not-exist")
 check(not app.content_sync.valid_recipes(broken,app.countries),"Reject invalid or excessive selection")
 broken=book.duplicate(true);broken.recipes.couscous.steps=[]
 check(not app.content_sync.valid_recipes(broken,app.countries),"Reject recipe without steps")
 app.show_country("DZA","Gastronomie");await shot("gastronomie")
 var b=find_button("Couscous")
 check(b!=null,"Algerian dish visible before essay")
 if b!=null:await tap(b.get_global_rect().get_center())
 check(find_button("Recettes du pays")!=null,"Touch opens complete recipe")
 await shot("recipe")
 app.scroll.scroll_vertical=100000;await process_frame;await shot("recipe_bottom")
 b=find_button("Recettes du pays")
 if b!=null:await tap(b.get_global_rect().get_center())
 check(find_button("Gastronomie du pays")!=null,"Return from recipe to country recipes")
 for code in ["FRA","TUR","IND","JPN","USA","NRU","VAT","ATA"]:
  app.show_country(code,"Gastronomie");await process_frame
 check(app.bottom.get_child_count()==3,"Explorer remains removed")
 check(app.TOPICS.has("Gastronomie"),"Country topic retained")
 print("RECIPES CHECKS: ","PASS" if failures.is_empty() else failures)
 quit(0 if failures.is_empty() else 1)
