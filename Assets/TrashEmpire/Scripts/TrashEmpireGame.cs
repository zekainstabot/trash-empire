using System.Collections.Generic;
using UnityEngine;

// A code-only prototype: the world and its UI are generated at runtime.
public sealed class TrashEmpireGame : MonoBehaviour
{
    public static TrashEmpireGame Instance { get; private set; }

    [Header("Starting economy")]
    [SerializeField] private int startingCash = 0;
    [SerializeField] private int startingCapacity = 5;
    [SerializeField] private float startingSpeed = 5f;

    private readonly List<Transform> trash = new List<Transform>();
    private CharacterController controller;
    private Transform player;
    private Camera gameCamera;
    private int cash;
    private int carried;
    private int capacity;
    private int speedLevel;
    private float moveSpeed;
    private Vector2 joystick;
    private bool joystickHeld;
    private string notice = "Collect trash and recycle it for cash!";
    private float noticeUntil;
    private GUIStyle labelStyle, buttonStyle, titleStyle;
    private bool initialized;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void AutoStart()
    {
        if (FindObjectOfType<TrashEmpireGame>() == null)
            new GameObject("Trash Empire Runtime").AddComponent<TrashEmpireGame>();
    }

    private void Awake()
    {
        if (Instance != null && Instance != this) { Destroy(gameObject); return; }
        Instance = this;
        cash = startingCash;
        capacity = startingCapacity;
        moveSpeed = startingSpeed;
        BuildWorld();
        initialized = true;
    }

    private Material Mat(Color color)
    {
        var material = new Material(Shader.Find("Standard"));
        material.color = color;
        return material;
    }

    private GameObject Cube(string name, Vector3 position, Vector3 scale, Color color)
    {
        var obj = GameObject.CreatePrimitive(PrimitiveType.Cube);
        obj.name = name;
        obj.transform.position = position;
        obj.transform.localScale = scale;
        obj.GetComponent<Renderer>().material = Mat(color);
        return obj;
    }

    private void BuildWorld()
    {
        RenderSettings.ambientLight = new Color(0.68f, 0.72f, 0.78f);
        RenderSettings.fog = true;
        RenderSettings.fogColor = new Color(0.68f, 0.75f, 0.78f);
        RenderSettings.fogDensity = 0.008f;

        var ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
        ground.name = "Recycling Yard";
        ground.transform.localScale = new Vector3(5, 1, 5);
        ground.GetComponent<Renderer>().material = Mat(new Color(0.34f, 0.39f, 0.32f));

        var sun = new GameObject("Sun").AddComponent<Light>();
        sun.type = LightType.Directional;
        sun.intensity = 1.15f;
        sun.transform.rotation = Quaternion.Euler(50, -35, 0);

        // Yard boundary and simple industrial scenery.
        for (int i = 0; i < 5; i++)
        {
            Cube("Fence Back " + i, new Vector3(-18 + i * 9, 1.1f, 23), new Vector3(8.5f, 2.2f, .35f), new Color(.22f,.25f,.24f));
            Cube("Fence Front " + i, new Vector3(-18 + i * 9, 1.1f, -23), new Vector3(8.5f, 2.2f, .35f), new Color(.22f,.25f,.24f));
        }
        Cube("Warehouse", new Vector3(17, 3, 14), new Vector3(10, 6, 9), new Color(.36f,.43f,.48f));
        Cube("Warehouse Door", new Vector3(11.9f, 2, 9.35f), new Vector3(.2f, 4, 4), new Color(.12f,.15f,.17f));

        // Recycling station: stand inside the marked green pad and sell.
        Cube("Recycling Station", new Vector3(0, .15f, 15), new Vector3(9, .3f, 7), new Color(.12f,.48f,.28f));
        Cube("Recycling Machine", new Vector3(0, 1.8f, 17), new Vector3(4, 3.3f, 2.5f), new Color(.12f,.32f,.23f));
        Cube("Machine Hopper", new Vector3(0, 3.7f, 17), new Vector3(2, .35f, 1.5f), new Color(.8f,.72f,.22f));

        var playerObject = GameObject.CreatePrimitive(PrimitiveType.Capsule);
        playerObject.name = "Player";
        playerObject.transform.position = new Vector3(0, 1, -5);
        playerObject.GetComponent<Renderer>().material = Mat(new Color(.18f,.42f,.82f));
        Destroy(playerObject.GetComponent<CapsuleCollider>());
        controller = playerObject.AddComponent<CharacterController>();
        controller.height = 2;
        controller.radius = .42f;
        controller.center = new Vector3(0, 0, 0);
        player = playerObject.transform;

        var camObject = new GameObject("Third Person Camera");
        gameCamera = camObject.AddComponent<Camera>();
        gameCamera.fieldOfView = 65;
        gameCamera.transform.position = player.position + new Vector3(0, 6, -8);
        gameCamera.transform.LookAt(player.position + Vector3.up);

        // Trash piles scattered around the yard.
        for (int i = 0; i < 24; i++)
        {
            float x = Random.Range(-17f, 13f);
            float z = Random.Range(-15f, 9f);
            if (Mathf.Abs(x) < 5 && z > 5) z = -4;
            var piece = GameObject.CreatePrimitive(i % 3 == 0 ? PrimitiveType.Sphere : PrimitiveType.Cube);
            piece.name = "Collectible Trash";
            piece.transform.position = new Vector3(x, .35f, z);
            piece.transform.localScale = new Vector3(Random.Range(.45f,.8f), Random.Range(.35f,.65f), Random.Range(.4f,.8f));
            piece.GetComponent<Renderer>().material = Mat(i % 2 == 0 ? new Color(.48f,.34f,.2f) : new Color(.25f,.48f,.5f));
            trash.Add(piece.transform);
        }
    }

    private void Update()
    {
        if (!initialized || player == null) return;
        Vector2 input = joystick;
        if (Input.touchCount == 0)
        {
            input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
        }
#if UNITY_EDITOR || UNITY_STANDALONE
        if (Input.GetKeyDown(KeyCode.E)) Collect();
        if (Input.GetKeyDown(KeyCode.Space)) Sell();
#endif
        Vector3 forward = gameCamera.transform.forward;
        forward.y = 0; forward.Normalize();
        Vector3 right = gameCamera.transform.right;
        right.y = 0; right.Normalize();
        Vector3 move = forward * input.y + right * input.x;
        if (move.sqrMagnitude > 1) move.Normalize();
        if (move.sqrMagnitude > .001f)
        {
            controller.Move(move * moveSpeed * Time.deltaTime);
            player.rotation = Quaternion.Slerp(player.rotation, Quaternion.LookRotation(move), 12 * Time.deltaTime);
        }
        if (!controller.isGrounded) controller.Move(Vector3.down * 12f * Time.deltaTime);

        Vector3 desired = player.position + new Vector3(0, 5.5f, -7.5f);
        gameCamera.transform.position = Vector3.Lerp(gameCamera.transform.position, desired, 8 * Time.deltaTime);
        gameCamera.transform.LookAt(player.position + Vector3.up * 1.1f);
    }

    private bool NearRecycle()
    {
        Vector3 p = player.position;
        return Vector2.Distance(new Vector2(p.x,p.z), new Vector2(0,15)) < 6.5f;
    }

    public void Collect()
    {
        if (carried >= capacity) { Notify("Bag full! Upgrade capacity or recycle your trash."); return; }
        Transform nearest = null;
        float best = 3.2f;
        foreach (var item in trash)
        {
            if (item == null) continue;
            float d = Vector3.Distance(player.position, item.position);
            if (d < best) { best = d; nearest = item; }
        }
        if (nearest == null) { Notify("Move closer to a trash pile."); return; }
        trash.Remove(nearest);
        Destroy(nearest.gameObject);
        carried++;
        Notify("Trash collected!");
    }

    public void Sell()
    {
        if (!NearRecycle()) { Notify("Go to the green recycling station to sell."); return; }
        if (carried == 0) { Notify("Your bag is empty."); return; }
        int earned = carried * 10;
        cash += earned;
        carried = 0;
        Notify("Recycled! +" + earned + " cash");
    }

    public void UpgradeCapacity()
    {
        int cost = 50 + (capacity - startingCapacity) * 25;
        if (cash < cost) { Notify("Not enough cash. Recycle more trash!"); return; }
        cash -= cost; capacity += 3;
        Notify("Bag capacity upgraded!");
    }

    public void UpgradeSpeed()
    {
        int cost = 75 + speedLevel * 50;
        if (cash < cost) { Notify("Not enough cash. Recycle more trash!"); return; }
        cash -= cost; speedLevel++; moveSpeed += .8f;
        Notify("Movement speed upgraded!");
    }

    private void Notify(string message) { notice = message; noticeUntil = Time.time + 2.5f; }

    private void OnGUI()
    {
        if (!initialized) return;
        float scale = Mathf.Clamp(Screen.width / 900f, .72f, 1.35f);
        GUI.matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, new Vector3(scale, scale, 1));
        float w = Screen.width / scale, h = Screen.height / scale;
        if (labelStyle == null)
        {
            labelStyle = new GUIStyle(GUI.skin.label) { fontSize = 23, fontStyle = FontStyle.Bold, normal = { textColor = Color.white } };
            titleStyle = new GUIStyle(labelStyle) { fontSize = 30 };
            buttonStyle = new GUIStyle(GUI.skin.button) { fontSize = 19, fontStyle = FontStyle.Bold, wordWrap = true };
        }
        GUI.color = new Color(0,0,0,.62f);
        GUI.Box(new Rect(16, 16, 300, 112), GUIContent.none);
        GUI.color = Color.white;
        GUI.Label(new Rect(30, 22, 280, 36), "TRASH EMPIRE", titleStyle);
        GUI.Label(new Rect(30, 62, 280, 30), "Cash: $" + cash + "   Bag: " + carried + "/" + capacity, labelStyle);
        GUI.Label(new Rect(30, 94, 280, 28), "Speed Lv. " + (speedLevel + 1), labelStyle);

        float buttonW = 190, buttonH = 58;
        if (GUI.Button(new Rect(w - buttonW - 20, h - 150, buttonW, buttonH), "COLLECT", buttonStyle)) Collect();
        if (GUI.Button(new Rect(w - buttonW - 20, h - 82, buttonW, buttonH), "SELL", buttonStyle)) Sell();
        if (GUI.Button(new Rect(20, h - 145, 210, 55), "BAG +3  ($" + (50 + (capacity-startingCapacity)*25) + ")", buttonStyle)) UpgradeCapacity();
        if (GUI.Button(new Rect(20, h - 80, 210, 55), "SPEED UP  ($" + (75 + speedLevel*50) + ")", buttonStyle)) UpgradeSpeed();

        if (Time.time < noticeUntil)
        {
            GUI.color = new Color(0,0,0,.7f);
            GUI.Box(new Rect(w*.25f, 145, w*.5f, 48), GUIContent.none);
            GUI.color = Color.white;
            GUI.Label(new Rect(w*.25f + 10, 150, w*.5f - 20, 40), notice, labelStyle);
        }
        GUI.color = Color.white;

        // Simple touch joystick in the lower-left quadrant.
        if (Input.touchCount > 0)
        {
            Touch t = Input.GetTouch(0);
            Vector2 pos = new Vector2(t.position.x / scale, h - t.position.y / scale);
            Rect area = new Rect(0, h - 340, w * .48f, 330);
            if (t.phase == TouchPhase.Began && area.Contains(pos)) joystickHeld = true;
            if (joystickHeld && area.Contains(pos))
            {
                Vector2 center = new Vector2(130, h - 160);
                joystick = Vector2.ClampMagnitude((pos - center) / 75f, 1f);
            }
            if (t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled) { joystickHeld = false; joystick = Vector2.zero; }
            GUI.color = new Color(1,1,1,.22f);
            GUI.Box(new Rect(55, h - 235, 150, 150), "MOVE");
            GUI.color = Color.white;
        }
    }
}
