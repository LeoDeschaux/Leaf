#pragma warning disable 168
using System;
using System.Collections;

using TinySoundFontBeef;
using static TinySoundFontBeef.TinySoundFontBeef;

namespace Leaf;

//https://github.com/EKA2L1/EKA2L1/blob/e67f84dc605ea30afc1ab6f4f43c0f855eec79a5/src/emu/drivers/src/audio/backend/tinysoundfont/player_tsf.cpp#L34

struct MidiEvent
{
	public enum Type
	{
		NoteOff,
		NoteOn,
		Other
	}

	public Type event = 0;
	public uint8 nKey = 0;
	public uint8 nVelocity = 0;
	public uint32 nDeltaTick = 0;

	public this(Type t)
	{
		event = t;
	}

	public this(Type t, uint8 key, uint8 velocity, uint32 deltaTick)
	{
		event = t;
		nKey = key;
		nVelocity = velocity;
		nDeltaTick = deltaTick;
	}
}

struct MidiNote
{
	public int nTrack = 0;

	public int nKey = 0;
	public int nVelocity = 0;
	public int nStartTime = 0;
	public int nDuration = 0;

	public this(int pKey, int pVelocity, int pStartTime, int pDuration, int pTrack)
	{
		nKey = pKey;
		nVelocity = pVelocity;
		nStartTime = pStartTime;
		nDuration = pDuration;

		nTrack = pTrack;
	}
}

class MidiTrack
{
	public String sName;
	public String sInstrument;
	public List<MidiEvent> Events = new .() ~ delete _;
	public List<MidiNote> Notes = new .() ~ delete _;
	public uint8 nMaxNote = 64;
	public uint8 nMinNote = 64;

	public ~this()
	{
		delete sName;
		delete sInstrument;
	}
}

class MidiFile
{
	public enum EventName : uint8
	{					
		VoiceNoteOff = 0x80,
		VoiceNoteOn = 0x90,
		VoiceAftertouch = 0xA0,
		VoiceControlChange = 0xB0,
		VoiceProgramChange = 0xC0,
		VoiceChannelPressure = 0xD0,
		VoicePitchBend = 0xE0,
		SystemExclusive = 0xF0,		
	}

	public enum MetaEventName : uint8
	{
		MetaSequence = 0x00,
		MetaText = 0x01,
		MetaCopyright = 0x02,
		MetaTrackName = 0x03,
		MetaInstrumentName = 0x04,
		MetaLyrics = 0x05,
		MetaMarker = 0x06,
		MetaCuePoint = 0x07,
		MetaChannelPrefix = 0x20,
		MetaEndOfTrack = 0x2F,
		MetaSetTempo = 0x51,
		MetaSMPTEOffset = 0x54,
		MetaTimeSignature = 0x58,
		MetaKeySignature = 0x59,
		MetaSequencerSpecific = 0x7F,

		MetaProgramName = 0x8,
		MetaDevicePort = 0x9,
		MetaMidiPort = 0x21,
	}

	public List<MidiTrack> Tracks = new .();
	public uint32 m_nTempo = 0;
	public uint32 m_nBPM = 0;

	public this()
	{
	}

	public this(String sFileName)
	{
		ParseFile(sFileName);
	}

	public ~this()
	{
		for(var e in Tracks)
			delete e;
		delete Tracks;

		tml_free(tml);
	}

	public tml_message* tml;

	public bool ParseFile(String sFileName)
	{
		tml = tml_load_filename(sFileName);

		Tracks.Add(new .());

		uint32 nWallTime = 0;
		List<MidiNote> listNotesBeingProcessed = scope .();

		while (tml != null) {

			var track = Tracks[0];

			nWallTime = tml.time;

			/*
			Console.WriteLine(scope $@"""
			{midiMessage.type},{(int)midiMessage.key},{(int)midiMessage.velocity},{midiMessage.time}
			""");
			*/

			if(tml.type == TMLMessageType.TML_NOTE_ON && (int)tml.velocity > 0)
			{
				listNotesBeingProcessed.Add(.((uint8)tml.key, (uint8)tml.velocity, (int)tml.time, 0, (int)tml.channel));
			}

			if (
				tml.type == TMLMessageType.TML_NOTE_OFF ||
				(tml.type == TMLMessageType.TML_NOTE_ON && (int)tml.velocity == 0
			))
			{
				var index = -1;//listNotesBeingProcessed.FindIndex(scope (n) => n.nKey == (uint)midiMessage.key);

				for(int i = listNotesBeingProcessed.Count-1; i >= 0; i--)
				{
					if(listNotesBeingProcessed[i].nKey == (.)tml.key)
					{
						index = i;
					}
				}

				if (index != -1)
				{
					var note = listNotesBeingProcessed[index];
					note.nDuration = (.)nWallTime - note.nStartTime;
					track.Notes.Add(note);
					track.nMinNote = (.)Math.Min(track.nMinNote, note.nKey);
					track.nMaxNote = (.)Math.Max(track.nMaxNote, note.nKey);
					listNotesBeingProcessed.RemoveAt(index);
				}
				else
				{
					Console.WriteLine("ERROR NOTE NOT FOUND");
				}
			}

		    tml = tml.next;
		}

		for(var note in Tracks[0].Notes)
		{
			//Log.Message(scope $"{note.nStartTime}, {note.nDuration}");
		}


		/*
		// Convert Time Events to Notes
		for (var track in Tracks)
		{
			uint32 nWallTime = 0;

			List<MidiNote> listNotesBeingProcessed = scope .();

			for (var event in track.Events)
			{
				nWallTime += event.nDeltaTick;

				if (event.event == MidiEvent.Type.NoteOn)
				{
					// New Note
					listNotesBeingProcessed.Add(.(event.nKey, event.nVelocity, nWallTime, 0));
				}

				if (event.event == MidiEvent.Type.NoteOff)
				{
					var index = listNotesBeingProcessed.FindIndex(scope (n) => n.nKey == event.nKey);

					if (index != -1)
					{
						var note = listNotesBeingProcessed[index];
						note.nDuration = nWallTime - note.nStartTime;
						track.Notes.Add(note);
						track.nMinNote = Math.Min(track.nMinNote, note.nKey);
						track.nMaxNote = Math.Max(track.nMaxNote, note.nKey);
						listNotesBeingProcessed.RemoveAt(index);
						//listNotesBeingProcessed.Remove(note);
					}
					else
					{
						Console.WriteLine("ERROR NOTE NOT FOUND");
					}
				}
			}
		}
		*/

		return true;
	}

}