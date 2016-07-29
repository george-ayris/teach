import renderPdf from './renderPdf';
import Elm from './Dev.elm';
import './index.html';

const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const app = Elm.Main.embed(mountNode);

app.ports.renderPdf.subscribe(model => {
  renderPdf(model);
});
