// representar pontos no espaço 
// conceito importante do CSS -> Ele faz uso de um plano cartesiano cujo ponto (0,0) é no canto superior esquerdo da tela, então 
// provavelmente só faremos uso de valores negativos de Y nos botões e positivos de X  

let windowWidth = screen.width;
let windowHeight = screen.height;

class GameObject{
	
	constructor(element, position){
		this.element = element;
		this.position = position;
		this.element.style.position = "absolute";
		this.setPosition(position);
			
	}
	
	setPosition(vector2){
		this.position = vector2;
		this.element.style.left = `${vector2.x}%`;
		this.element.style.top = `${vector2.y}%`;			
	}
}

class Vector2{
	constructor(x, y){
		this.x = x;
		this.y = y;
	}
	
	getX(){
		return this.x;
	}
	
	setX(x){
		if (Number.isFinite(x))	{
			this.x = x;
		} else {
			return;
		}
	}
	
	getY(){
			return this.y;
		}
		
	setY(y){
		if (Number.isFinite(y)){
			this.y = y;	
		} else {
			return;
		}
	}
		 
	getSpacePosition(){
		return new Vector2(this.x, this.y);
	}
	
	getDistance(p1, p2){
		//d = raíz de (x2² - x1²) + (y2² - y2²)
		return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
	}
	
	
	// o que eu vou precisar -> método de settar posição e método de pegar distância 
	
	
}