<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function() {

		pageList(1, 2);
//全选控制
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked)  //这行表示：如果this。checked为true，那么给每一个类型为
															  //input且name=xz的标签赋值为checked

		})
//反向全选
		$("#transactionBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)

		})
//查询按钮
		$("#searchBtn").click(function () {

			$("#hidden-name").val($.trim($("#search-owner").val()))
			$("#hidden-owner").val($.trim($("#search-name").val()))
			$("#hidden-customerId").val($.trim($("#search-customerId").val()))
			$("#hidden-stage").val($.trim($("#search-stage").val()))
			$("#hidden-source").val($.trim($("#search-source").val()))
			$("#hidden-type").val($.trim($("#search-type").val()))
			$("#hidden-ContactsId").val($.trim($("#search-ContactsId").val()))

			pageList(1, 2)
		})
//编辑按钮
		$("#editBtn").click(function () {
			var $xz = $("input[name=xz]:checked")
			if ($xz.length == 0) {
				alert("请选择你要修改的交易")
			} else if ($xz.length > 1) {
				alert("每次修改只能选择一个交易,默认进入选中列表的的第一个交易")
			}
		})
//删除按钮
		$("#deleteBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择需要删除的交易")
			}else {
				if(confirm("确定删除选中的交易吗？")){
					var param=""
					for(var i=0 ;i<$xz.length;i++){
						param += "id="+$($xz[i]).val() // 这里的$$有两个.第一个表示将jquery数组中的单个（即dom对象）转换为jquery对象。
						// 这样才能使用val（）。这里还可以写作$xz[i].value
						if(i<$xz.length-1){
							param += "&";       //这里拼接的是地址栏的参数。因为是参数。所以地址栏会自动在第一个参数前添加”？“
						}
					}
					//alert(param)
					$.ajax({
						url:"workbench/transaction/delete.do",
						data:param,          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if(data.success){
								pageList(1,$("#transactionPage").bs_pagination('getOption', 'rowsPerPage'));

								// pageList(1,2)

							}else {
								alert("删除交易活动失败")
							}


						}
					})

				}

			}
		})
	});




//分页
	function pageList(pageNo,pageSize) {
		$("#qx").prop("checked",false)
		$.ajax({
			url:"workbench/transaction/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				<%--"id":${}--%>//这里没有要id！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
				"owner":$.trim($("#search-owner").val()),
				"name":$.trim($("#search-name").val()),
				"customerId":$.trim($("#search-customerId").val()),
				"stage":$.trim($("#search-stage").val()),
				"type":$.trim($("#search-type").val()),
				"source":$.trim($("#search-source").val()),
				"contactsId":$.trim($("#search-contactsId").val())

			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {

				//这里需要返回两条数据.把两个数据封装成一个对象了
				// 一是：总的数据条目数，二是：交易的列表集合
				//{"total":100,"dataList":[{交易1},{2},{3}，.....]}
				var html="";
				$.each(data.dataList,function (i,n) {
					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/transaction/detail.do?id='+n.id+'\';">'+n.customerId+'——'+n.name+'</a></td>';

					html += '<td>'+n.name+'</td>';
					html += '<td>'+n.stage+'</td>';
					html += '<td>'+n.type+'</td>';
					html += '<td>'+n.owner+'</td>';
					html += '<td>'+n.source+'</td>';
					html += '<td>'+n.contactsId+'</td>';
					html += '</tr>';
				})

				$("#transactionBody").html(html);

				var totalPages=data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1; //注意这里处理的parseInt

				//数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#transactionPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数实在，点击分页组件的时候触发的；
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);//这个data  不是我们自己传的那个data。这里的数据不要动
					}
				});
			}
		})
	}
	
</script>
</head>
<body>


			<input type="hidden" id="hidden-owner">
			<input type="hidden" id="hidden-name">
			<input type="hidden" id="hidden-customerId">
			<input type="hidden" id="hidden-stage">
			<input type="hidden" id="hidden-type">
			<input type="hidden" id="hidden-source">
			<input type="hidden" id="hidden-contactsId">

	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="search-stage">
					  	<option></option>
					  	<c:forEach items="${stageList}" var="s">
							<option value="${s.text}">${s.value}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="search-type">
					  	<option></option>
						   <c:forEach items="${transactionTypeList}" var="t"><%--交易类型的名字特殊！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1				  --%>
							   <option value="${t.text}">${t.value}</option>
						   </c:forEach>
					  </select>
				    </div>
				  </div>
<%--				  --%>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						 <option></option>
						  <c:forEach items="${sourceList}" var="s">
							  <option value="${s.text}">${s.value}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="search-contactsId">
				    </div>
				  </div>
				  
				  <button type="button"  id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/add.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn" onclick="window.location.href='workbench/transaction/edit.do?id='+$('input[name=xz]:checked').val()+'';" ><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="transactionBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/detail.jsp';">动力节点-交易01</a></td>--%>
<%--							<td>动力节点</td>--%>
<%--							<td>谈判/复审</td>--%>
<%--							<td>新业务</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>广告</td>--%>
<%--							<td>李四</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点-交易01</a></td>--%>
<%--                            <td>动力节点</td>--%>
<%--                            <td>谈判/复审</td>--%>
<%--                            <td>新业务</td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>广告</td>--%>
<%--                            <td>李四</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 20px;" >
				<div id="transactionPage">
<%--					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>--%>
<%--				</div>--%>
<%--				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>--%>
<%--					<div class="btn-group">--%>
<%--						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">--%>
<%--							10--%>
<%--							<span class="caret"></span>--%>
<%--						</button>--%>
<%--						<ul class="dropdown-menu" role="menu">--%>
<%--							<li><a href="#">20</a></li>--%>
<%--							<li><a href="#">30</a></li>--%>
<%--						</ul>--%>
<%--					</div>--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>--%>
<%--				</div>--%>
<%--				<div style="position: relative;top: -88px; left: 285px;" >--%>
<%--					<nav>--%>
<%--						<ul class="pagination">--%>
<%--							<li class="disabled"><a href="#">首页</a></li>--%>
<%--							<li class="disabled"><a href="#">上一页</a></li>--%>
<%--							<li class="active"><a href="#">1</a></li>--%>
<%--							<li><a href="#">2</a></li>--%>
<%--							<li><a href="#">3</a></li>--%>
<%--							<li><a href="#">4</a></li>--%>
<%--							<li><a href="#">5</a></li>--%>
<%--							<li><a href="#">下一页</a></li>--%>
<%--							<li class="disabled"><a href="#">末页</a></li>--%>
<%--						</ul>--%>
<%--					</nav>--%>
				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>