using System;using System.Linq;using System.Collections.Generic;using System.Threading.Tasks;using System.Web.Script.Serialization;
public partial class TV {
 void ApplyAiResponse(string response,HashSet<string> allowed){ApplyParsedAiResponse(response,allowed);}
 async Task<string> ApplyChange(string mode,string id){if(mode!="disable"&&mode!="uninstall")throw new Exception("未知操作");if(!ScanReady())throw new Exception("请先扫描当前电视");if(!System.Text.RegularExpressions.Regex.IsMatch(id??"",@"^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)*$"))throw new Exception("无效包名");if(!packages.Any(p=>p.Id==id&&(p.State=="已安装"||p.State=="已停用")))throw new Exception("应用不在当前已安装清单");if(mode=="disable")return await Shell("pm disable-user --user 0 "+id);string result="";try{result=await Shell("pm uninstall --user 0 "+id);}catch(Exception ex){result=ex.Message;}if(result.IndexOf("Success",StringComparison.OrdinalIgnoreCase)>=0)return result;string disabled=await Shell("pm disable-user --user 0 "+id);return "当前用户卸载未成功，已尝试停用："+result+" / "+disabled;}
}

