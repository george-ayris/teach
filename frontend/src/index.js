import Elm from './App.elm';
import './index.html';
import registerPorts from './js/ports'

const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const app = Elm.Main.embed(mountNode);

registerPorts(app.ports);
