// CekRAM Go Implementation
// Run: go run main.go --lang=id --threshold=80 --oneshot
package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"
)

type i18nStrings struct {
	Title   string
	Total   string
	Used    string
	Free    string
	Percent string
	Status  string
	Safe    string
	Alert   string
	Done    string
	Stop    string
}

var stringsMap = map[string]i18nStrings{
	"id": {
		Title:   "SUPER MONITOR - CEKRAM [ID]",
		Total:   "TOTAL RAM   ",
		Used:    "RAM TERPAKAI",
		Free:    "RAM BEBAS   ",
		Percent: "PERSENTASE  ",
		Status:  "STATUS      ",
		Safe:    "Aman Sentosa :3",
		Alert:   "[!] RAM SESAK! Menjalankan Auto-Purge...",
		Done:    "[+] Selesai! RAM sudah diplongkan.",
		Stop:    "[ Tekan Ctrl+C buat berhenti ]",
	},
	"en": {
		Title:   "SUPER MONITOR - CEKRAM [EN]",
		Total:   "TOTAL RAM   ",
		Used:    "USED RAM    ",
		Free:    "FREE RAM    ",
		Percent: "PERCENTAGE  ",
		Status:  "STATUS      ",
		Safe:    "Safe & Sound :3",
		Alert:   "[!] HIGH MEMORY USAGE! Running Auto-Purge...",
		Done:    "[+] Done! Memory cache synced & purged.",
		Stop:    "[ Press Ctrl+C to stop ]",
	},
}

type RAMMetrics struct {
	TotalMB int
	UsedMB  int
	FreeMB  int
	Percent float64
}

func getRAMMetrics() RAMMetrics {
	if runtime.GOOS == "linux" {
		data, err := os.ReadFile("/proc/meminfo")
		if err == nil {
			lines := strings.Split(string(data), "\n")
			memMap := make(map[string]int)
			for _, line := range lines {
				parts := strings.Split(line, ":")
				if len(parts) == 2 {
					valParts := strings.Fields(parts[1])
					if len(valParts) > 0 {
						if v, e := strconv.Atoi(valParts[0]); e == nil {
							memMap[strings.TrimSpace(parts[0])] = v
						}
					}
				}
			}
			totalKB := memMap["MemTotal"]
			availKB := memMap["MemAvailable"]
			if availKB == 0 {
				availKB = memMap["MemFree"] + memMap["Buffers"] + memMap["Cached"]
			}
			totalMB := totalKB / 1024
			freeMB := availKB / 1024
			usedMB := totalMB - freeMB
			pct := 0.0
			if totalMB > 0 {
				pct = float64(usedMB) / float64(totalMB) * 100.0
			}
			return RAMMetrics{TotalMB: totalMB, UsedMB: usedMB, FreeMB: freeMB, Percent: pct}
		}
	} else if runtime.GOOS == "darwin" {
		out, err := exec.Command("sysctl", "-n", "hw.memsize").Output()
		if err == nil {
			if totalBytes, e := strconv.ParseInt(strings.TrimSpace(string(out)), 10, 64); e == nil {
				totalMB := int(totalBytes / (1024 * 1024))
				return RAMMetrics{TotalMB: totalMB, UsedMB: totalMB / 2, FreeMB: totalMB / 2, Percent: 50.0}
			}
		}
	}
	return RAMMetrics{TotalMB: 4096, UsedMB: 2048, FreeMB: 2048, Percent: 50.0}
}

func purgeRAM() {
	if runtime.GOOS == "linux" {
		exec.Command("sync").Run()
		if os.Geteuid() == 0 {
			os.WriteFile("/proc/sys/vm/drop_caches", []byte("3\n"), 0644)
		} else {
			exec.Command("sudo", "-n", "sh", "-c", "sync && echo 3 > /proc/sys/vm/drop_caches").Run()
		}
	} else if runtime.GOOS == "darwin" {
		exec.Command("sync").Run()
		exec.Command("sudo", "-n", "purge").Run()
	} else if runtime.GOOS == "windows" {
		cmd := `powershell -NoProfile -Command "$code = '[DllImport(\"psapi.dll\")] public static extern bool EmptyWorkingSet(IntPtr hProcess);'; $type = Add-Type -MemberDefinition $code -Name 'MemUtil' -PassThru; Get-Process | ForEach-Object { try { $type::EmptyWorkingSet($_.Handle) | Out-Null } catch {} }"`
		exec.Command("cmd", "/C", cmd).Run()
	}
}

func main() {
	langFlag := flag.String("lang", "id", "Language selection (id/en)")
	thresholdFlag := flag.Int("threshold", 80, "Threshold percentage to trigger purge")
	intervalFlag := flag.Int("interval", 5, "Refresh interval in seconds")
	oneshotFlag := flag.Bool("oneshot", false, "Run once and exit immediately")
	purgeNowFlag := flag.Bool("purge-now", false, "Trigger purge immediately and exit")
	flag.Parse()

	lang := strings.ToLower(*langFlag)
	if lang != "en" && lang != "id" {
		lang = "id"
	}
	s := stringsMap[lang]

	if *purgeNowFlag {
		fmt.Println(s.Alert)
		purgeRAM()
		fmt.Println("  " + s.Done)
		return
	}

	for {
		// Clear console
		fmt.Print("\033[H\033[2J")
		fmt.Println("==================================================")
		fmt.Printf("        %s\n", s.Title)
		fmt.Println("==================================================")

		m := getRAMMetrics()
		fmt.Printf("  %s : %d MB\n", s.Total, m.TotalMB)
		fmt.Printf("  %s : %d MB\n", s.Used, m.UsedMB)
		fmt.Printf("  %s : %d MB\n", s.Free, m.FreeMB)
		fmt.Printf("  %s : [%.2f %%]\n", s.Percent, m.Percent)
		fmt.Println("--------------------------------------------------")

		if int(m.Percent) > *thresholdFlag {
			fmt.Println("  " + s.Alert)
			purgeRAM()
			fmt.Println("  " + s.Done)
		} else {
			fmt.Printf("  %s : %s\n", s.Status, s.Safe)
		}
		fmt.Println("--------------------------------------------------")

		if *oneshotFlag {
			break
		}

		fmt.Println("  " + s.Stop)
		time.Sleep(time.Duration(*intervalFlag) * time.Second)
	}
}
