<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){

		$(".time").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});



		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});


		showRemarkList();


		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})

		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})



       //页面加载完毕，展示关联的市场活动列表
		showActivityList();

		//为线索中的备注，添加“ 保存” 按钮事件
		$("#remarkBtn").click(function () {

			var content=$("#remark").val();//这里仍旧是textarea 但是因为textarea特殊，将其按照val来取值。这一点要记住
			$.ajax({
				url:"workbench/clue/saveRemark.do",
				data:{      "noteContent":$.trim(content),
					"clueId" :"${c.id}"// js中使用EL表达式必须加上双引号
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/fales，"cr":{备注信息整体}
					if(data.success){
						//添加成功后，把文本域中的内容清空掉
						$("#remark").val("");
						var html="";
						//添加成功，在textarea上方添加一个div

						html += '<div id='+data.cr.id+' class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
						//这里对照下面的备注模板要少一行。因为下面的备注模板是写死的，连位置都是写死的。所以这一行不要
						html += '<h5 id="e'+data.cr.id+'">'+data.cr.noteContent+'</h5>';
						//下面给加的id，为了方便得到活动的名称，更新这个过程中，只能改备注信息。其他的活动名称什么的都不变。给id拼接了个s
						html += '<font color="gray">线索</font> <font color="gray">-</font> <b>${c.fullname}-${c.appellation}</b> <small style="color: gray;" id="s'+data.cr.id+'"> '+(data.cr.createTime)+' 由'+(data.cr.createBy)+'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						//注意这里onclick="editRemark(\''+n.id+'\')"给备注信息 的两个图标帮了id
						html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
						html += '&nbsp;&nbsp;&nbsp;&nbsp;';
						html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
						//javascript:void(0) 表示禁止使用超链接
						/*
                        之所以是在动态生成的图标中绑定click方法，是因为。若是我们使用id的方式，因为是动态生成的。这样的话，
                        每个市场活动的评论的id都一样了。导致删除的时候会出错。

                        */
						html += '</div>';
						html += '</div>';
						html += '</div>';


						$("#remarkDiv").before(html)



					}else {
						alert("添加备注失败")
					}


				}
			})


		})

//备注的更新按钮，
		$("#updateRemarkBtn").click(function () {
			//这里由于下面还要使用id，所以将其放到ajax外面。若是放到ajax里面，写两遍一摸一样的显得麻烦
			var id=$("#remarkId").val();
			$.ajax({
				url:"workbench/clue/updateRemark.do",
				data:{      "id":id,
					"noteContent":$.trim($("#noteContent").val())// 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/false,"cr":{备注信息整体}
					if(data.success){
						//修改成功，
						//根据返回来的数据，更新展现出来的备注信息。

						//下面的更新操作全部是按照已有的备注的div的内容去传值的

						//这里是展示更新后的备注信息到div
						//是给动态生成的那些div更改信息。！！！！！！！！！！！！！！！！！！！！！！！！！！！1
						$("#e"+id).html(data.cr.noteContent)//这里是对h5标签对里面的信息操作，所以使用html
						// <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
						//将上面的small里面的信息更改!!。small也是标签对!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						$("#s"+id).html(data.cr.editTime+" 由"+data.cr.editBy)

						//更改信息后，关闭模态窗口
						$("#editRemarkModal").modal("hide")


					}else {
						alert("修改备注失败")
					}


				}
			})

		})

		//为关联市场活动的模态窗口中的 搜索框 绑定事件 点击  回车，进行查询操作
		$("#aname").keydown(function (event) {
			if(event.keyCode==13){

				$.ajax({
					url:"workbench/clue/getActivityByNameAndNotByClueId.do",
					data:{
						  "clueId":"${c.id}",
						   "aname":$.trim($("#aname").val())
					},
					type:"get",
					dataType: "json",                                 //这里是你想要的数据类型
					success:function (data) {
						/*
						data[{活动1}{2}{3}]
						 */
						//妈的！！！！！！！！！！！！这里返回的是要立马展现出来的内容。根本不用判断if。这里返回的只是一个集合。哪里有success！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
							var html="";
							$.each(data,function (i,n) {
							html += '<tr>';
							html += '<td><input  type="checkbox" value="'+n.id+'" name="xz"/></td>';
							html += '<td>'+n.name+'</td>';
							html += '<td>'+n.startDate+'</td>';
							html += '<td>'+n.endDate+'</td>';
							html += '<td>'+n.owner+'</td>';
							html += '</tr>';
							})

						$("#activitySearchBody").html(html);
					}
				})
				return false//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			}
		})
//全选
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked)  //这行表示：如果this。checked为true，那么给每一个类型为
															  //input且name=xz的标签赋值为checked

		})
//反向全选
		$("#activitySearchBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)

		})


		//关联的按钮
		$("#guanlianBtn").click(function () {
			var $xz=$("input[name=xz]:checked")//切记这里有个checked！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
			if($xz.length==0){
				alert("请选择你要关联的活动")
			}
			else{
				//url:workbench/clue/guanlian.do?cid=xxx&aid=xxx&aid=xxx
				var param = "cid=${c.id}&"
				for(var i=0;i<$xz.length;i++){
					param += "aid="+$($xz[i]).val();//~~~~~~~~```!!!!注意这里$xz[i]为dom，$($xz[i])才为jquery对象!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
				    if(i<$xz.length-1){
				    	param += "&";
					}
				}

				//alert(param)
			$.ajax({
				url:"workbench/clue/guanlian.do",
				data:param,                   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
					data{"success":true/false}
					 */
					if(data.success){
						//刷新关联活动的列表
						showActivityList();
						//清除搜索框中的信息， 取消总的复选框的勾号，取消筛选出来的内容
						$("#aname").val("")
						$("#qx").prop("checked",false)
						$("#activitySearchBody").html("")
						//关闭模态窗口
						$("#bundModal").show("hide")


					}
					else {
						alert("关联新的市场活动失败")
					}


				}
			})

		}

	})
		//为线索的详细信息页面的修改 做更新绑定操作
		$("#updateBtn").click(function () {
			$.ajax({
				url:"workbench/clue/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),//id为隐藏域中的id，是编辑窗口打开后才生成的id

					"owner":$.trim($("#edit-owner").val()),
					"company":$.trim($("#edit-company").val()),
					"appellation":$.trim($("#edit-appellation").val()),
					"fullname":$.trim($("#edit-fullname").val()),
					"job":$.trim($("#edit-job").val()),
					"email":$.trim($("#edit-email").val()),
					"phone":$.trim($("#edit-phone").val()),
					"website":$.trim($("#edit-website").val()),
					"mphone":$.trim($("#edit-mphone").val()),
					"state":$.trim($("#edit-state").val()),
					"source":$.trim($("#edit-source").val()),
					"description":$.trim($("#edit-description").val()),
					"contactSummary":$.trim($("#edit-contactSummary").val()),
					"nextContactTime":$.trim($("#edit-nextContactTime").val()),
					"address":$.trim($("#edit-address").val())

				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
					data
					{"data":true/false}
					 */
					if(data.success){
						window.location.reload();

						//成功后关闭模态窗口；，但是前面用了刷新这里就不用再隐藏了。因为刷新会自动将其关闭
						//$("#editClueModal").modal("hide")

						//刷新列表！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！111

					}
					else {
						alert("更新线索失败")
					}


				}
			})


		})



});


	function showRemarkList() {

		$.ajax({
			url:"workbench/clue/getRemarkListByCid.do",
			data:{
				     "clueId":"${c.id}"             //此处注意是EL表达式 。在js中使用el表达式必须加上“”  。此处的a是ActivityCOntroller类中的的detail方法的值。是一个活动对象。将其放在了request区域中          // 这里是你传递的数据!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				//data
				// [{备注1} {备注2}.....]
				var html="";

				$.each(data,function (i,n) {
					//关于字符串拼接。因为最原本的里面用的“”双引号比较多，所以在拼接的时候选择在最外面添加单引号
					//下面的这个  $ {c.name} 是从request区域中获得的。


					html += '<div id='+n.id+' class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
					//这里对照下面的备注模板要少一行。因为下面的备注模板是写死的，连位置都是写死的。所以这一行不要
					html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
					//下面给加的id，为了方便得到活动的名称，更新这个过程中，只能改备注信息。其他的活动名称什么的都不变。给id拼接了个s
					html += '<font color="gray">线索</font> <font color="gray">-</font> <b>${c.fullname}-${c.appellation}</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					//注意这里onclick="editRemark(\''+n.id+'\')"给备注信息 的两个图标帮了id
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					//javascript:void(0) 表示禁止使用超链接
					/*
					之所以是在动态生成的图标中绑定click方法，是因为。若是我们使用id的方式，因为是动态生成的。这样的话，
					每个市场活动的评论的id都一样了。导致删除的时候会出错。

					*/
					html += '</div>';
					html += '</div>';
					html += '</div>';
				})

				//下面使用的before 是在思考之后使用的
				/*
				思考如下：如果直接在 ”大备注”上添加id，然后使用html。那么会覆盖掉“大备注” 。之前都是这么做的，
				         那是因为里面都是空的，不存在覆盖的情况。
				所以做法有两种。1. 是在“大备注”下面写一个空的div，然后使用id和html。这样就不会覆盖掉大备注
				               2. 使用append或者before。此处的做法是使用了before
				 */
				$("#remarkDiv").before(html)



			}
		})

	}

	function editRemark(id) {
		//alert(id)

		//将编辑的模态窗口的隐藏域中的id进行赋值!!!!!!!!!!!这个难理解一点
		$("#remarkId").val(id);

		//找到指定的存放备注信息的h5标签
		var noteContent=$("#e"+id).html();//这行操作一定要会！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
		//将h5中展现你出来的原始信息，赋予到修改操作的模态窗口的文本域中
		$("#noteContent").val(noteContent);

		//以上信息处理完毕后，将修改备注的模态窗口打开
		$("#editRemarkModal").modal("show")


	}
    //点击 叉号  删除备注
	function deleteRemark(id) {  //上面使用这个方法传参的时候。字符串的拼接我真的看不懂！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
		//课中讲的是因为是动态生成的元素所触发的方法的参数必须套在字符串当中
		//alert(id)
		if(confirm("确认删除该备注吗？")){
			$.ajax({
				url:"workbench/clue/deleteRemark.do",
				data:{   "id":id                              // 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					// { "success":true/false}
					if(data.success){


						//showRemarkList();
						//showRemarkList(); 这样写会导致越删除越多。因为他虽然删除了数据。
						// 但是不会清空之前已经读出来的,因为使用的是before方法
						//所以会不断增多.所以改进如下

						$("#"+id).remove();//首先在动态生成的语句中，为每个活动备注加上id。。这是一个小技巧！！！！！！！！！！！！！！！！！！！！！
						//注意这里$("#"+id)的特殊方式。表示的意思是根据每个线索备注的id
						//去找到对应div块。即活动备注。然后删除他即可



					}
					else {
						alert("删除备注失败");
					}


				}
			})

		}


	}

	function showActivityList() {
		$.ajax({
			url:"workbench/clue/getAcitivityListByClueId.do",
			data:{
				"clueId": "${c.id}"                        // 这里是你传递的数据
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				var html="";
				$.each(data,function (i,n) {
					/*
					data
					[{市场活动1}{市场活动2}{市场活动2}]
					 */
					html += "<tr>"
					html += "<td>"+n.name+"</td>"
					html += "<td>"+n.startDate+"</td>"
					html += "<td>"+n.endDate+"</td>"
					html += "<td>"+n.owner+"</td>"
					//下面的这个id表面上为市场活动的id.但是我们在sql中处理过。其实际是线索活动关系表的主键id
					html += '<td><a href="javascript:void(0);" onclick="unbind(\''+n.id+'\')"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>'
					html += "</tr>"
				})

				$("#activityBody").html(html)





			}
		})


	}

    function unbind(id){
            /*通过市场活动id和（线索和活动关系表）中的线索id 才能删除， 关系表中的一条记录
            若是仅仅通过市场活动id就删除关系表的内容，会导致出错。因为这是  多对多  。
            一个市场活动可能会对应好几个线索，也即好几条关系记录
            但是，我们这样做太麻烦了
            我们希望unbind(id)中的id就是关联关系表中的id!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
             经过上面的动态生成处理后， 现在传入的参数id就是关系表中的id.
             */
            //alert(id)
            $.ajax({
                url: "workbench/clue/unbind.do",
                data: {
                    "id": id// 这里是你传递的数据
                },
                type: "get",
                dataType: "json",                                 //这里是你想要的数据类型
                success: function (data) {
                    /*
                    data{"success":ture/false}
                     */
                    if (data.success) {
                        //刷新市场活动列表
                        showActivityList();
                    }else {
                        alert("取消绑定活动失败");
                    }
                }
            })
	}
	//线索详细也中的编辑按钮 绑定事件
	function bianji(id) {

		$.ajax({
			url:"workbench/clue/getUserListAndClue.do",
			data:{
				"id":id,                           // 传递过去的被选中的活动的id!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				/*
                data
                用户对象
                线索活动列表
                {"uList":[{用户1}，{2}，{3}]，"c":{一条线索}}
                */
				var html="<option></option>";

				$.each(data.uList,function (i,n) {
					if(data.c.owner==n.id){
						html += " <option value='"+n.id+" 'selected>"+n.name+"</option>"
					}
					else
						html += " <option value='"+n.id+"'>"+n.name+"</option>"
				})

				$("#edit-owner").html(html);//这一行已经有了用户的id

				$("#edit-id").val(data.c.id) //这个是从后台传递回来的线索的id，放到隐藏区域的id中！！！！！！！！！！！！！！

				$("#edit-company").val(data.c.company)
				$("#edit-appellation").val(data.c.appellation)
				$("#edit-fullname").val(data.c.fullname)
				$("#edit-job").val(data.c.job)
				$("#edit-email").val(data.c.email)

				$("#edit-phone").val(data.c.phone)
				$("#edit-website").val(data.c.website)
				$("#edit-fullname").val(data.c.fullname)
				$("#edit-mphone").val(data.c.mphone)
				$("#edit-state").val(data.c.state)

				$("#edit-source").val(data.c.source)
				$("#edit-description").val(data.c.description)
				$("#edit-contactSummary").val(data.c.contactSummary)
				$("#edit-nextContactTime").val(data.c.nextContactTime)
				$("#edit-address").val(data.c.address)



				//所有的东西都写好后，显示出来模态窗口
				$("#editClueModal").modal("show")

			}
		})

	}

	//为线索详细页面的 删除操作 进行绑定事件
	function shanchu(id) {
		if(confirm("确定要删除吗？如果删除，将不能进行转换。请仔细考虑是否真的要删除！！")){
			var param="id="+id;
			$.ajax({
				url:"workbench/clue/delete.do",//这里使用的是同一个方法，即index也i按的批量删除的方法
				data:param,
				type:"post",     //删除操作，使用post
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
                    data
                    {"success":true/false}
                     */
					if(data.success){
						// $.ajax({
						// 	url:"workbench/activity/shuaxin.do",
						//
						// 	type:"get",
						// 	dataType: "json",                                 //这里是你想要的数据类型
						//
						// })
						<%--					<jsp:forward page="/workbench/activity/index.jsp"></jsp:forward>--%>
						//history.back();
						//window.location.reload();
						var url=document.referrer;//获取上一个页面的地址
						window.location.href=url;//重新进入到这个页面。等同于刷新一次

					}else {
						alert("删除线索活动失败")
					}


				}
			})
		}

	}

</script>

</head>
<body>


<!-- 修改线索备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
	<%-- 备注的id --%>
	<input type="hidden" id="remarkId">

	<div class="modal-dialog" role="document" style="width: 40%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabelQ">修改备注</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form">
					<div class="form-group">
						<label for="noteContent" class="col-sm-2 control-label">内容</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="noteContent"></textarea>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
			</div>
		</div>
	</div>
</div>

	<!-- 关联市场活动的模态窗口 -->
	<div class="modal fade" id="bundModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;"  id="aname" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="qx"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">



						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="guanlianBtn">关联</button>
				</div>
			</div>
		</div>
	</div>

    <!-- 修改线索的模态窗口 -->
    <div class="modal fade" id="editClueModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 90%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改线索</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">

                        <div class="form-group">
                            <label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-owner">

                                </select>
                            </div>
                            <label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-company" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-appellation">
									<c:forEach items="${appellationList}" var="a">
										<%--									 value 是此处字典七大类型中每一大类的值。是数据库中的列名--%>
										<option value="${a.value}">${a.text}</option>
									</c:forEach>

                                </select>
                            </div>
                            <label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-fullname" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-job" class="col-sm-2 control-label">职位</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-job" >
                            </div>
                            <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-email" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-phone" >
                            </div>
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-mphone" >
                            </div>
                            <label for="edit-state" class="col-sm-2 control-label">线索状态</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-state">
									<c:forEach items="${clueStateList}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>

                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-source" class="col-sm-2 control-label">线索来源</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-source">
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.value}">${s.text}</option>
									</c:forEach>

                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-description" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-description"></textarea>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="edit-nextContactTime" >
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" data-dismiss="modal" id="updateBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${c.fullname}${c.appellation} <small>${c.company}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='workbench/clue/convert.jsp?id=${c.id}&fullname=${c.fullname}&appellation=${c.appellation}&company=${c.company}&owner=${c.owner}';"><span class="glyphicon glyphicon-retweet"></span> 转换</button>
			<button type="button" class="btn btn-default" onclick="bianji('${c.id}')"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" onclick="shanchu('${c.id}')"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.fullname}${c.appellation}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.owner}</b></div>  <%--这里的owner已经在sql语句中处理为中文名字了	--%>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.company}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;&nbsp;${c.job}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">线索状态</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.state}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">修改者</div>
<%--			下面的    &nbsp是用来占位的，要不然横线会跑到上面，如若没有填写内容的话--%>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${c.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${c.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 100px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					&nbsp;${c.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 40px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
<%--		<!-- 备注1 -->--%>
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>哎呦！</h5>--%>
<%--				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>
		
<%--	--%>
<%--		</div>	<!-- 备注2 -->--%>
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>呵呵！</h5>--%>
<%--				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="remarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityBody">

					</tbody>
				</table>
			</div>
			
			<div>
				<a  href="#" data-toggle="modal" data-target="#bundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
<div style="height: 200px;"></div>
</body>
</html>