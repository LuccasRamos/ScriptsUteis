<script src="js/pdfmake.min.js"></script>
<script src="js/vfs_fonts.js"></script>

$scope.gerarPDF = function() {
html2canvas(document.getElementById('exportthis'), {
            onrendered: function (canvas) {
                var data = canvas.toDataURL();
                var docDefinition = {
                	footer: {
					    columns: [
					      'Left part',
					      { text: 'Right part', alignment: 'right' }
					    ]
					  },
                   		 content: [{
                       		 image: data,
                       		 width: 500,
                   		 }]
                };
            	pdfMake.createPdf(docDefinition).download("Score_Details.pdf");
            }
        });
}

	$scope.atualizarPagina = function(){
		$state.go('dashboard.relatorios',{}, {reload: true});
	}

<div id="exportthis"> 
  <h1><span class="glyphicon glyphicon-list-alt"></span> Relatorio de ocorrencias mensais </h1>
    <div donut-chart="" donut-data="ctrl.chartData" donut-colors="ctrl.chartColors" donut-formatter="'currency'"></div>
    <div bar-chart bar-data="chartData" bar-x='y' bar-y='["a"]' bar-labels='["Publicações"]' bar-colors='["#31C0BE"]'></div>

    <br>
    <br>
    <table class="table table-striped">
        <thead>
            <tr>
                <td><h3><b>Ordem</b></h3></td>
                <td><h3><b>Mês</b></h3></td>
                <td><h3><b>Quantidade de Ocorrência</b></h3></td>
            </tr>
        </thead>
        <tbody>
          <tr ng-repeat="ocorrencia in ocorrencia2">
              <td><h4>{{$index}}</h4></td>
              <td><h4>{{ocorrencia.MES}}</h4></td>
              <td><h4>{{ocorrencia.NUMERO}}</h4></td>
          </tr>
        </tbody> 
    </table>
    </div>
    </div>
    </div>
</div>
