using System;using System.IO;
class MockAdb{
 static int Main(string[] args){string cmd=string.Join(" ",args);File.AppendAllText("mock-commands.log",cmd+"\n");
 if(cmd.Contains("exec-out screencap")){byte[] png=Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1sAAAAASUVORK5CYII=");using(var output=Console.OpenStandardOutput())output.Write(png,0,png.Length);return 0;}
 if(cmd.Contains("get-state")){Console.WriteLine("device");return 0;}
 if(cmd.Contains("devices")){Console.WriteLine("List of devices attached\n192.0.2.1:5555\tdevice");return 0;}
 if(cmd.Contains("pm list packages -u -f")){Console.WriteLine("package:/system/priv-app/SystemUI/SystemUI.apk=com.android.systemui\npackage:/data/app/demo/base.apk=com.demo.video\npackage:/system/app/Removed/base.apk=com.demo.removed\npackage:/system/app/Home/base.apk=com.vendor.tvhome\npackage:/data/app/Launcher/base.apk=com.new.launcher");return 0;}
 if(cmd.Contains("pm list packages -d")){if(File.Exists("disabled.flag"))Console.WriteLine("package:com.demo.video");return 0;}
 if(cmd.Contains("pm list packages -s")){Console.WriteLine("package:com.android.systemui\npackage:com.vendor.tvhome\npackage:com.demo.removed");return 0;}
 if(cmd.Contains("pm list packages")){Console.WriteLine("package:com.android.systemui\npackage:com.vendor.tvhome\npackage:com.new.launcher");if(!File.Exists("removed.flag"))Console.WriteLine("package:com.demo.video");return 0;}
 if(cmd.Contains("query-activities")){Console.WriteLine("com.vendor.tvhome/.Main\ncom.new.launcher/.Main");return 0;}
 if(cmd.Contains("resolve-activity")){Console.WriteLine(File.Exists("newhome.flag")?"com.new.launcher/.Main":"com.vendor.tvhome/.Main");return 0;}
 if(cmd.Contains("set-home-activity")){File.WriteAllText("newhome.flag","");Console.WriteLine("Success");return 0;}
 if(cmd.Contains("pm path")){Console.WriteLine("package:/data/app/demo/base.apk");return 0;}
 if(cmd.Contains("pm uninstall")&&File.Exists("uninstall-fails.flag")){Console.WriteLine("Failure [DELETE_FAILED_INTERNAL_ERROR]");return 0;}
 if(cmd.Contains("pm disable-user")&&File.Exists("disable-fails.flag")){Console.Error.WriteLine("disable rejected");return 1;}
 if(cmd.Contains("pm disable-user"))File.WriteAllText("disabled.flag","");if(cmd.Contains("pm uninstall"))File.WriteAllText("removed.flag","");
 if(cmd.Contains("install-existing")){if(File.Exists("removed.flag"))File.Delete("removed.flag");Console.WriteLine("Package com.demo.video installed for user: 0");return 0;}
 if(cmd.Contains("pm enable")&&File.Exists("disabled.flag"))File.Delete("disabled.flag");
 if(cmd.Contains("ls -1ap")){Console.WriteLine("Movies/\nhello world.txt");return 0;}
 Console.WriteLine("Success");return 0;}}
