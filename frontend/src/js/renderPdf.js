import PdfDocument from 'pdfkit';
import blobStream from 'blob-stream';

const renderPdf = model => {
  console.log('Render: ', model);
  const pdf = new PdfDocument();
  const stream = pdf.pipe(blobStream());

  pdf.fontSize(20);
  pdf.text(model.title, {
    underline: true,
    align: 'center'
  });

  pdf.end();

  stream.on('finish', () => {
    const blob = stream.toBlob('application/pdf');
    const url = stream.toBlobURL('application/pdf');
    window.open(url);
  });
};

export default renderPdf;
