trigger ContactTrigger on Contact(before insert, before update, after insert)
{
    new ContactTriggerHandler().run();
}