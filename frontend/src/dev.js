import Elm from './Dev.elm';
import './index.html';
import registerPorts from './js/ports'
import './sass/main.scss'

const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const app = Elm.Main.embed(mountNode);

registerPorts(app.ports);
