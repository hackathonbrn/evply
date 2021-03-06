import pixi.plugins.app.Application;
import js.Browser;
import editor.gui.CursorSelector;
import editor.gui.ScaleSelector;
import editor.workspace.Workspace;
import pixi.core.display.Container;
import pixi.core.math.shapes.Rectangle;
import pixi.interaction.InteractionEvent;
import pixi.core.math.Point;
import pixi.interaction.InteractionData;
import pixi.loaders.Loader;
import editor.workspace.Node;
import interpreter.Evaluator;

enum PointerBehaviourType {
	Select;
	Zoom;
	Move;
}

enum InputType {
	Text;
	Symbol;
	Number;
}

class Main extends Application {

	var pointerState: PointerBehaviourType;
	var dragStart: Point;
	var dragEnd: Point;
	var dragData: InteractionData;
	var wsPosBuffer: Point;
	var workspace: Null<Workspace>;
	var isDragging: Bool;
	var loader: Loader;
	var pictureSelector: Null<editor.gui.PictureSelector>;
	var boolSelector: Null<editor.gui.BoolSelector>;
	var evalSelector: editor.gui.EvalSelector;
	var evaluator: Evaluator;

	var inputType: InputType = Text;

	public function new() {
		super();

		evaluator = new Evaluator();

		Browser.document.body.addEventListener("contextmenu", function(e) {
			if (e.button == 2) {
				e.preventDefault();
			}
		});

		Browser.document.body.addEventListener("keydown", function(e) {
			if (e.shiftKey == true && workspace != null) {
				workspace.shiftPressed = true;
			}

			if (e.keyCode == 46) {
				workspace.deleteSelected();
			}
		});

		Browser.document.body.addEventListener("keyup", function(e) {
			if (workspace != null) {
				workspace.shiftPressed = false;
				
			}
		});

		Browser.document.querySelector("#string_btn").addEventListener("click", function() {
			inputType = Text;
		});

		Browser.document.querySelector("#symbol_btn").addEventListener("click", function() {
			inputType = Symbol;
		});

		
		Browser.document.querySelector("#number_btn").addEventListener("click", function() {
			inputType = Number;
		});

		Browser.document.querySelector("#submit_btn").addEventListener("click", function() {
			if (workspace != null) {
				switch (inputType) {
					case Text:
						var txt = untyped __js__('document.querySelector("#input_bar").value');
						var text = new editor.workspace.nodes.Text(txt);
						text.x = -workspace.x + width/2 - text.width;
						text.y = -workspace.y + height/2;
						workspace.addNode(text);
					case Number:
						var txt: String = untyped __js__('document.querySelector("#input_bar").value');
						var num = Std.parseFloat(txt);
						if (!Math.isNaN(num)) {
							var number = new editor.workspace.nodes.Number(num);
							number.x = -workspace.x + width/2 - number.width;
							number.y = -workspace.y + height/2;
							workspace.addNode(number);
						}
					case Symbol:
						var txt = untyped __js__('document.querySelector("#input_bar").value');
						var text = new editor.workspace.nodes.Symbol(txt);
						text.x = -workspace.x + width/2 - text.width;
						text.y = -workspace.y + height/2;
						workspace.addNode(text);
				}
			}
		});

		Browser.document.querySelector("#picture_btn").addEventListener("click", function() {
			if (workspace != null && pictureSelector != null) {
				pictureSelector.visible = true;
			}
		});

		Browser.document.querySelector("#bool_btn").addEventListener("click", function() {
			if (workspace != null && boolSelector != null) {
				boolSelector.visible = true;
			}
		});

		Browser.document.querySelector("#lambda_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				switch (args.type) {
					case RList(_):

					case _:
						return;
				}

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				llist.push(new editor.workspace.nodes.Lambda.LambdaPicture());

				var lambda = new editor.workspace.nodes.Lambda(llist);
				lambda.x = -workspace.x + width/2 - lambda.width;
				lambda.y = -workspace.y + height/2;
				workspace.addNode(lambda);
			}
		});

		Browser.document.querySelector("#parens_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				var parens = new editor.workspace.ListNode(llist);
				parens.x = -workspace.x + width/2 - parens.width;
				parens.y = -workspace.y + height/2;
				workspace.addNode(parens);
			}
		});

		Browser.document.querySelector("#def_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				llist.push(new editor.workspace.nodes.Symbol.Define());

				var parens = new editor.workspace.ListNode(llist);
				parens.x = -workspace.x + width/2 - parens.width;
				parens.y = -workspace.y + height/2;
				workspace.addNode(parens);
			}
		});

		Browser.document.querySelector("#quote_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				llist.push(new editor.workspace.nodes.Symbol.Quote());

				var parens = new editor.workspace.ListNode(llist);
				parens.x = -workspace.x + width/2 - parens.width;
				parens.y = -workspace.y + height/2;
				workspace.addNode(parens);
			}
		});

		Browser.document.querySelector("#if_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				llist.push(new editor.workspace.nodes.Symbol.Conditional());

				var parens = new editor.workspace.ListNode(llist);
				parens.x = -workspace.x + width/2 - parens.width;
				parens.y = -workspace.y + height/2;
				workspace.addNode(parens);
			}
		});

		Browser.document.querySelector("#list_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				llist.push(new editor.workspace.nodes.Symbol.ListSymbol());

				var parens = new editor.workspace.ListNode(llist);
				parens.x = -workspace.x + width/2 - parens.width;
				parens.y = -workspace.y + height/2;
				workspace.addNode(parens);
			}
		});

		Browser.document.querySelector("#begin_btn").addEventListener("click", function() {
			if (workspace != null) {
				var args = workspace.selectedNodes.first();
				if (args == null) return;

				var llist = new List<Node>();
				for (i in workspace.selectedNodes) {
					llist.add(i);
				}

				llist.push(new editor.workspace.nodes.Symbol.Begin());

				var parens = new editor.workspace.ListNode(llist);
				parens.x = -workspace.x + width/2 - parens.width;
				parens.y = -workspace.y + height/2;
				workspace.addNode(parens);
			}
		});

		backgroundColor = 0xF5F5DC;
		width = Browser.window.innerWidth;
		height = Browser.window.innerHeight;
		position = "fixed";
		antialias = true;

		super.start(null, Browser.document.body);

		loader = new Loader("assets/");
		loader.add("cursor", "cursor.png");
		loader.add("lambda", "lambda.png");
		loader.add("hand", "hand.png");
		loader.add("eval", "eval.png");
		loader.add("closure", "closure.png");
		loader.add("magnifier", "magnifier.png");
		loader.add("pictures", "pictures.json");
		loader.load(init);
	}

	function init() {
		pointerState = Select;
		isDragging = false;

		onUpdate = update;

		// Слой для очистки выделения
		var screenUnselectLayer = new Container();
		screenUnselectLayer.hitArea = new Rectangle(0, 0, width, height);
		screenUnselectLayer.interactive = true;
		screenUnselectLayer.on("pointerdown", function() {
			if (workspace != null) workspace.clearSelection();
		});

		stage.addChild(screenUnselectLayer);

		// Рабочее пространство
		workspace = new Workspace();
		wsPosBuffer = new Point(workspace.position.x, workspace.position.y);
		stage.addChild(workspace);

		// Промежуточный слой для d'n'd и зума
		var screenTransformLayer = new Container();

		screenTransformLayer.hitArea = new Rectangle(0, 0, width, height);
		screenTransformLayer.interactive = true;
		screenTransformLayer.visible = false;

		screenTransformLayer.on("pointerdown", onDragStart);
		screenTransformLayer.on("pointerup", onDragEnd);
		screenTransformLayer.on("pointermove", onDragMove);
		stage.addChild(screenTransformLayer);

		// Меню выбора поведения курсора
		var cursorSelector = new CursorSelector(
			function() { pointerState = Select; screenTransformLayer.visible = false; setCursor(Select); }, 
			function() { pointerState = Move; screenTransformLayer.visible = true; setCursor(Move); },
			function() { pointerState = Zoom; screenTransformLayer.visible = true; setCursor(Zoom); }); 


		cursorSelector.position.x = 10;
		cursorSelector.position.y = 10;

		stage.addChild(cursorSelector);

		// Меню zoom-in / zoom-out
		var scaleSelector = new ScaleSelector(
			function() workspace.zoom(-0.1), 
			function() workspace.zoom(0.1));

		scaleSelector.position.x = 10;
		scaleSelector.position.y = height - 45;

		stage.addChild(scaleSelector);

    	pictureSelector = new editor.gui.PictureSelector(width * 0.25, height * 0.1, width/2, height * 0.8, workspace, this);
		pictureSelector.visible = false;
		stage.addChild(pictureSelector);

		boolSelector = new editor.gui.BoolSelector(width * 0.25, height * 0.3, width/2, height * 0.3, workspace, this);
		boolSelector.visible = false;
		stage.addChild(boolSelector);

		evalSelector = new editor.gui.EvalSelector(function() {
			// trace(workspace.selectedNodes.first().serialize());
			var expr = evaluator.eval(workspace.selectedNodes.first().astfize(), evaluator.globalScope);		
			var rExpr = evaluator.objectize(expr);

			if (rExpr == null) return;
			
			var node = switch(rExpr) {
				case RNumber(number):
					new editor.workspace.nodes.Number(number);
				case RString(string):
					new editor.workspace.nodes.Text(string);
				case RSymbol(string):
					new editor.workspace.nodes.Symbol(string);
				case RBoolean(boolean):
					new editor.workspace.nodes.Boolean(boolean);
				case RPicture(x, y):
					new editor.workspace.nodes.Picture(x, y);
				case RList(list):
					new editor.workspace.ListNode(list);
				// case RLambdaSymbol:
					// new editor.workspace.nodes.Lambda();
				// case RQuoteSymbol:
				// case RIfSymbol:
				// case RDefSymbol:
				// case RListSymbol:
				// case RBegin:
				case _:
					null;
			}

			if (node != null) {
				node.x = -workspace.x + width/2 - node.width;
				node.y = -workspace.y + height/2;
				workspace.addNode(node);
			}
		});
		evalSelector.position.set(150, 10);
		evalSelector.visible = false;
		workspace.evalSelector = evalSelector;
		stage.addChild(evalSelector);
	}

	function setCursor(type: PointerBehaviourType) {
		Browser.document.body.style.cursor = switch (type) {
			case Select:
				"default";
			case Move:
				"grab";
			case Zoom:
				"zoom-in";
		}
	}

	function onDragStart(event: InteractionEvent) {
		switch (pointerState) {
			case Select:

			case Zoom:
				var button = cast(untyped __js__("event.data.originalEvent.button"), Int);
				if (button == 0) {
					workspace.zoom(0.1);
				} else if (button == 2) {
					workspace.zoom(-0.1);
				}
			case Move:
				dragStart = event.data.getLocalPosition(stage);
				dragData = event.data;
				isDragging = true;
				wsPosBuffer.x = workspace.position.x;
				wsPosBuffer.y = workspace.position.y;
		}
	}

	function onDragMove() {
		if (pointerState == Move && isDragging) {
			dragEnd = dragData.getLocalPosition(stage);
			dragEnd.x = dragEnd.x - dragStart.x;
			dragEnd.y = dragEnd.y - dragStart.y;
			workspace.position.x = wsPosBuffer.x + dragEnd.x;
			workspace.position.y = wsPosBuffer.y + dragEnd.y;
		}
	}

	function onDragEnd() {
		if (pointerState == Move) {
			isDragging = false;
		}
	}

	// var zoom = false;

	function update(e: Float) {
		// if (zoom)
		// 	workspace.zoom(-Math.atan(e*0.01));
	}

	function createJson():String {
		var str = "";
		for (i in workspace.nodes) {
			str += i.serialize() + ",";
		}

		return str;
	}

	static function main() {
		new Main();
	}
}