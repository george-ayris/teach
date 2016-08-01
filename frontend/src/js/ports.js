import renderPdf from './renderPdf';

const registerPorts = elmPorts => {
  elmPorts.renderPdf.subscribe(model => {
    renderPdf(model);
  });

  elmPorts.imageUploaded.subscribe(info => {
    console.log(info);
    const file = document.getElementById(info.elementId).files[0];

    const fileReader = new FileReader();
    fileReader.onload = e =>
      elmPorts.imageUploadedResult.send({
        questionId: info.questionId,
        name: file.name,
        result: e.target.result
      });
    

    fileReader.readAsDataURL(file);
  });
};

export default registerPorts;
