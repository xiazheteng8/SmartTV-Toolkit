using System;using System.IO;using System.Text.RegularExpressions;using System.Collections.Generic;using System.Web.Script.Serialization;
public partial class TV {
 public class ClassificationRule{public string group;public string pattern;public string reason;public bool core;}
 public class ClassificationTable{public string version;public ClassificationRule fallback;public List<ClassificationRule> rules;}
 static ClassificationTable classification;
 public static ClassificationRule ClassifyPackage(string id){if(classification==null)classification=new JavaScriptSerializer().Deserialize<ClassificationTable>(File.ReadAllText(Root+"classification-rules.json"));foreach(var rule in classification.rules)if(Regex.IsMatch(id??"",rule.pattern,RegexOptions.IgnoreCase))return rule;return classification.fallback;}
 string OriginalCategory(string id){return ClassifyPackage(id).group;}
}
