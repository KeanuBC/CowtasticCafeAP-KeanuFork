using UnityEngine;

public class SoundEffectManager : MonoBehaviour
{
    public AudioSource AS;

    [Header("Effects")]
    public AudioClip LevelUp;
    public AudioClip NewOrder;
    public AudioClip MouseClick;
    public AudioClip MenuSelection;
    public AudioClip FlusterMilk;

    public static SoundEffectManager instance;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
    }

    // Start is called before the first frame update
    //void Start()
    //{

    //}

    // Update is called once per frame
    //void Update()
    //{

    //}

    public void PlayLevelUpEffect()
    {
        PlaySoundOneShot(LevelUp);
    }

    public void PlayNewOrderEffect()
    {
        PlaySoundOneShot(NewOrder);
    }

    /// <summary>Cue played when a customer flusters and starts wanting breast milk.</summary>
    public void PlayFlusterMilkEffect()
    {
        PlaySoundOneShot(FlusterMilk);
    }

    public void PlayMenuSelection()
    {
        PlaySoundOneShot(MenuSelection);
    }

    public void PlayMouseClick()
    {
        PlaySoundOneShot(MouseClick);
    }

    public void PlaySoundOneShot(AudioClip clip)
    {
        if (clip == null)
        {
            return;
        }
        AS.PlayOneShot(clip);
    }
}
