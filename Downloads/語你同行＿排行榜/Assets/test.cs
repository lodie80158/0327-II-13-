using UnityEngine;
using TMPro;
using System.Collections.Generic;
using System.Linq;

#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

public class test : MonoBehaviour
{
    [System.Serializable]
    public class PlayerData
    {
        public string name;
        public int steps;

        public PlayerData(string name, int steps)
        {
            this.name = name;
            this.steps = steps;
        }
    }

    public TextMeshProUGUI[] userTexts;
    private List<PlayerData> players = new List<PlayerData>();
    private int simulatedStepCount = 0;
    private Vector3 previousAcceleration;
    private float threshold = 1.0f;
    private float timeBetweenSteps = 0.5f;
    private float lastStepTime = 0;

#if UNITY_IOS && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void RequestHealthKitAuthorization();

    [DllImport("__Internal")]
    private static extern void GetThisWeekStepCount();

    [DllImport("__Internal")]
    private static extern void GetTodayStepCount();

    [DllImport("__Internal")]
    private static extern void GetYesterdayStepCount();
#endif

    void Start()
    {
        Screen.orientation = ScreenOrientation.AutoRotation;
        Screen.autorotateToPortrait = false;
        Screen.autorotateToPortraitUpsideDown = false;
        Screen.autorotateToLandscapeLeft = true;
        Screen.autorotateToLandscapeRight = true;

        players.Add(new PlayerData("Average", 0));
        players.Add(new PlayerData("LastYou", 0));
        players.Add(new PlayerData("You", 0));

#if UNITY_IOS && !UNITY_EDITOR
        RequestHealthKitAuthorization();
#endif

        previousAcceleration = Input.acceleration;
    }

    void Update()
    {
#if UNITY_EDITOR
        if (Input.GetKeyDown(KeyCode.Alpha1)) players[0].steps += 100;
        if (Input.GetKeyDown(KeyCode.Alpha2)) players[1].steps += 100;
        if (Input.GetKeyDown(KeyCode.Alpha3)) players[2].steps += 100;

        Vector3 currentAcceleration = Input.acceleration;
        float accelerationChange = (currentAcceleration - previousAcceleration).magnitude;

        if (accelerationChange > threshold && (Time.time - lastStepTime) > timeBetweenSteps)
        {
            simulatedStepCount++;
            lastStepTime = Time.time;
            players[2].steps = simulatedStepCount;
        }

        previousAcceleration = currentAcceleration;
#endif

        UpdateLeaderboard();
    }

    void FetchSteps()
    {
#if UNITY_IOS && !UNITY_EDITOR
        GetThisWeekStepCount();
        GetTodayStepCount();
        GetYesterdayStepCount();
#endif
    }

    public void OnHealthKitAuthorizationSuccess()
    {
        Debug.Log("HealthKit 授權成功，開始讀取步數");
        FetchSteps();
    }

    public void OnThisWeekStepCountReceived(string count)
    {
        if (int.TryParse(count, out int parsedCount))
        {
            if (parsedCount <= 0)
                Debug.LogWarning("⚠️ 接收到週步數為 0，可能是權限未開啟或無資料");

            int avg = Mathf.RoundToInt(parsedCount / 7f);
            players[0].steps = avg;
            UpdateLeaderboard();
        }
        else
        {
            Debug.LogWarning("⚠️ 無法解析週步數：" + count);
        }
    }

    public void OnTodayStepCountReceived(string count)
    {
        if (int.TryParse(count, out int parsedCount))
        {
            if (parsedCount <= 0)
                Debug.LogWarning("⚠️ 接收到今日步數為 0，可能是權限未開啟或無資料");

            players[2].steps = parsedCount;
            UpdateLeaderboard();
        }
        else
        {
            Debug.LogWarning("⚠️ 無法解析今日步數：" + count);
        }
    }

    public void OnYesterdayStepCountReceived(string count)
    {
        if (int.TryParse(count, out int parsedCount))
        {
            if (parsedCount <= 0)
                Debug.LogWarning("⚠️ 接收到昨日步數為 0，可能是權限未開啟或無資料");

            players[1].steps = parsedCount;
            UpdateLeaderboard();
        }
        else
        {
            Debug.LogWarning("⚠️ 無法解析昨日步數：" + count);
        }
    }

    void UpdateLeaderboard()
    {
        var sorted = players.OrderByDescending(p => p.steps).ToList();
        for (int i = 0; i < userTexts.Length; i++)
        {
            if (i < sorted.Count)
            {
                string trophy = (i == 0) ? "" : "";
                userTexts[i].text = $"{i + 1}. {sorted[i].name} - {sorted[i].steps} steps{trophy}";
            }
            else
            {
                userTexts[i].text = "";
            }
        }
    }
}
